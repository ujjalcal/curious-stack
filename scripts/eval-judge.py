#!/usr/bin/env python3
"""
Three-tier judgment engine for agent skill evals.

Tier 1: Deterministic checks (free) — must_contain, must_not_contain, output_regex, verdict match
Tier 2: Fuzzy structural checks (free) — signal matching with token overlap
Tier 3: LLM-as-judge (costs tokens) — only when rubric is present

Usage:
    python3 eval-judge.py <output_file> <eval_case_json> [--skill-description "..."] [--judge-runner <runner>]

    Reads the skill output from <output_file> and the eval case from <eval_case_json>.
    Prints a JSON result to stdout.
"""

import json
import re
import sys
import os
import subprocess
import argparse
from pathlib import Path

repo_root = Path(__file__).resolve().parent.parent

# Verdict ordinal scale — extend as needed per skill
VERDICT_SCALE = {
    "clean": 0,
    "mild slop": 1,
    "heavy slop": 2,
    "pure slop": 3,
}


def parse_verdict_from_output(output: str) -> str | None:
    """Extract the VERDICT line from skill output."""
    match = re.search(r"VERDICT:\s*(.+)", output, re.IGNORECASE)
    if match:
        return match.group(1).strip().lower()
    return None


def parse_signals_from_output(output: str) -> list[str]:
    """Extract signal/pattern names from TOP ISSUES section."""
    signals = []
    # Match lines like: 1. Pattern Name — "quoted text"
    # or: 1. **Pattern Name** — "quoted text"
    for match in re.finditer(
        r"^\s*\d+\.\s+\*{0,2}([^—\*\n]+?)\*{0,2}\s*—", output, re.MULTILINE
    ):
        signals.append(match.group(1).strip().lower())
    return signals


def fuzzy_signal_match(expected: str, actual_list: list[str]) -> bool:
    """Check if an expected signal roughly matches any actual signal."""
    expected_lower = expected.lower()
    expected_tokens = set(expected_lower.split())

    for actual in actual_list:
        # Exact substring match
        if expected_lower in actual or actual in expected_lower:
            return True
        # Token overlap — if >50% of expected tokens appear in actual
        actual_tokens = set(actual.split())
        overlap = expected_tokens & actual_tokens
        if len(overlap) >= len(expected_tokens) * 0.5:
            return True
    return False


# ── Tier 1: Deterministic Checks ─────────────────────────────────────


def check_must_contain(output: str, must_contain: list[str]) -> dict:
    """Check that all required substrings appear in the output."""
    missing = []
    for phrase in must_contain:
        if phrase.lower() not in output.lower():
            missing.append(phrase)
    return {
        "check": "must_contain",
        "passed": len(missing) == 0,
        "missing": missing,
    }


def check_must_not_contain(output: str, must_not_contain: list[str]) -> dict:
    """Check that no prohibited substrings appear in the output."""
    found = []
    for phrase in must_not_contain:
        if phrase.lower() in output.lower():
            found.append(phrase)
    return {
        "check": "must_not_contain",
        "passed": len(found) == 0,
        "found": found,
    }


def check_output_regex(output: str, pattern: str) -> dict:
    """Check that output matches a regex pattern."""
    try:
        match = bool(re.search(pattern, output, re.MULTILINE))
    except re.error as e:
        return {"check": "output_regex", "passed": False, "error": str(e)}
    return {"check": "output_regex", "passed": match, "pattern": pattern}


def check_verdict(
    output: str, expected_verdict: str, tolerance: int = 0
) -> dict:
    """Check verdict on ordinal scale with tolerance."""
    actual = parse_verdict_from_output(output)
    if actual is None:
        return {
            "check": "verdict",
            "passed": False,
            "expected": expected_verdict,
            "actual": None,
            "reason": "No VERDICT line found in output",
        }

    expected_lower = expected_verdict.lower()

    # If verdicts aren't in our scale, fall back to exact match
    if expected_lower not in VERDICT_SCALE or actual not in VERDICT_SCALE:
        passed = expected_lower == actual
        return {
            "check": "verdict",
            "passed": passed,
            "expected": expected_verdict,
            "actual": actual,
            "reason": "exact match" if passed else "mismatch (not in ordinal scale)",
        }

    distance = abs(VERDICT_SCALE[expected_lower] - VERDICT_SCALE[actual])
    passed = distance <= tolerance
    return {
        "check": "verdict",
        "passed": passed,
        "expected": expected_verdict,
        "actual": actual,
        "distance": distance,
        "tolerance": tolerance,
    }


# ── Tier 2: Fuzzy Structural Checks ──────────────────────────────────


def check_signals(
    output: str,
    expected_signals: list[str],
    threshold: float = 0.5,
) -> dict:
    """Fuzzy-match expected signals against actual output."""
    actual_signals = parse_signals_from_output(output)
    matched = []
    unmatched = []

    for signal in expected_signals:
        if fuzzy_signal_match(signal, actual_signals):
            matched.append(signal)
        else:
            unmatched.append(signal)

    ratio = len(matched) / len(expected_signals) if expected_signals else 1.0
    return {
        "check": "signals",
        "passed": ratio >= threshold,
        "ratio": round(ratio, 2),
        "threshold": threshold,
        "matched": matched,
        "unmatched": unmatched,
        "actual_signals": actual_signals,
    }


# ── Tier 3: LLM-as-Judge ─────────────────────────────────────────────


def run_judge(
    output: str,
    rubric: str,
    skill_description: str,
    input_text: str,
    runner: str = "auto",
) -> dict:
    """Score output using LLM-as-judge. Returns score 1-5."""
    rubric_template = """# Eval Judge

You are judging the output of an AI skill.

**Skill:** {skill_description}
**Input:** {input}
**Output to judge:** {output}
**Rubric:** {rubric}

Score the output 1-5:
- 5: Excellent — fully meets the rubric, specific, actionable
- 4: Good — meets most criteria, minor gaps
- 3: Acceptable — meets minimum bar but has clear weaknesses
- 2: Poor — misses key criteria, vague or off-target
- 1: Failed — does not meet the rubric at all

Respond with exactly:
SCORE: <1-5>
REASON: <one sentence explaining your score>
"""

    judge_prompt = rubric_template.replace("{skill_description}", skill_description)
    judge_prompt = judge_prompt.replace("{input}", input_text[:500])  # truncate long inputs
    judge_prompt = judge_prompt.replace("{output}", output[:2000])
    judge_prompt = judge_prompt.replace("{rubric}", rubric)

    # Write prompt to temp file
    import tempfile
    with tempfile.NamedTemporaryFile(mode="w", suffix=".md", delete=False) as f:
        f.write(judge_prompt)
        prompt_file = f.name

    try:
        # Detect runner
        runners_dir = repo_root / "scripts" / "runners"
        if runner == "auto":
            result = subprocess.run(
                [str(runners_dir / "detect-runner.sh")],
                capture_output=True, text=True
            )
            runner = result.stdout.strip() if result.returncode == 0 else "none"

        if runner == "none":
            return {
                "check": "judge",
                "passed": False,
                "score": 0,
                "reason": "No LLM runner available for judging",
                "skipped": True,
            }

        # Pick runner script
        if runner == "claude-code":
            runner_script = str(runners_dir / "claude-code.sh")
        else:
            runner_script = str(runners_dir / "api-generic.sh")

        # Run judge
        result = subprocess.run(
            [runner_script, prompt_file, ""],  # no input needed, it's in the prompt
            capture_output=True, text=True, timeout=60
        )
        judge_output = result.stdout.strip()

        # Parse SCORE: N
        score_match = re.search(r"SCORE:\s*(\d)", judge_output)
        reason_match = re.search(r"REASON:\s*(.+)", judge_output)

        if score_match:
            score = int(score_match.group(1))
            reason = reason_match.group(1).strip() if reason_match else ""
            return {
                "check": "judge",
                "passed": score >= 3,
                "score": score,
                "normalized": round((score - 1) / 4, 2),  # 1-5 → 0.0-1.0
                "reason": reason,
            }
        else:
            return {
                "check": "judge",
                "passed": False,
                "score": 0,
                "reason": f"Could not parse judge output: {judge_output[:200]}",
            }
    except subprocess.TimeoutExpired:
        return {
            "check": "judge",
            "passed": False,
            "score": 0,
            "reason": "Judge timed out",
        }
    except Exception as e:
        return {
            "check": "judge",
            "passed": False,
            "score": 0,
            "reason": str(e),
        }
    finally:
        os.unlink(prompt_file)


# ── Scoring ───────────────────────────────────────────────────────────


def compute_score(tier1_results: list, tier2_result: dict | None, tier3_result: dict | None) -> dict:
    """Compute final weighted score from all tiers."""
    # Tier 1: any failure = hard fail
    tier1_passed = all(r["passed"] for r in tier1_results)
    if not tier1_passed:
        return {
            "score": 0.0,
            "passed": False,
            "reason": "Tier 1 deterministic check failed",
        }

    # Verdict score (from tier 1 verdict check, if present)
    verdict_score = 1.0
    for r in tier1_results:
        if r["check"] == "verdict":
            if r["passed"]:
                # Score based on distance: 0 distance = 1.0, at tolerance = 0.5
                distance = r.get("distance", 0)
                tolerance = r.get("tolerance", 0)
                verdict_score = 1.0 - (distance / (tolerance + 1)) * 0.5 if tolerance > 0 else 1.0
            else:
                verdict_score = 0.0

    # Tier 2 signal score
    signal_score = tier2_result["ratio"] if tier2_result else 1.0

    # Tier 3 judge score
    judge_score = tier3_result.get("normalized", 0.5) if tier3_result and not tier3_result.get("skipped") else None

    # Weighted average
    if judge_score is not None:
        final = 0.4 * verdict_score + 0.3 * signal_score + 0.3 * judge_score
    else:
        # No judge — reweight
        final = 0.6 * verdict_score + 0.4 * signal_score

    return {
        "score": round(final, 2),
        "passed": final >= 0.5,
        "verdict_score": round(verdict_score, 2),
        "signal_score": round(signal_score, 2),
        "judge_score": round(judge_score, 2) if judge_score is not None else None,
    }


# ── Main ──────────────────────────────────────────────────────────────


def judge(output: str, case: dict, skill_description: str = "", runner: str = "auto") -> dict:
    """Run all applicable tiers on a single output + case pair."""
    tier1_results = []
    tier2_result = None
    tier3_result = None

    # Tier 1
    if case.get("must_contain"):
        tier1_results.append(check_must_contain(output, case["must_contain"]))

    if case.get("must_not_contain"):
        tier1_results.append(check_must_not_contain(output, case["must_not_contain"]))

    if case.get("output_regex"):
        tier1_results.append(check_output_regex(output, case["output_regex"]))

    if case.get("expected_verdict"):
        tolerance = case.get("verdict_tolerance", 0)
        tier1_results.append(check_verdict(output, case["expected_verdict"], tolerance))

    # Tier 2
    if case.get("expected_signals"):
        threshold = case.get("signal_match_threshold", 0.5)
        tier2_result = check_signals(output, case["expected_signals"], threshold)

    # Tier 3
    if case.get("rubric") and runner != "skip":
        tier3_result = run_judge(
            output=output,
            rubric=case["rubric"],
            skill_description=skill_description,
            input_text=case.get("input", ""),
            runner=runner,
        )

    # Compute final score
    scoring = compute_score(tier1_results, tier2_result, tier3_result)

    return {
        "case_id": case.get("id", case.get("description", "unknown")),
        "tier1": tier1_results,
        "tier2": tier2_result,
        "tier3": tier3_result,
        "scoring": scoring,
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Judge skill output against eval case")
    parser.add_argument("output_file", help="File containing skill output")
    parser.add_argument("case_json", help="JSON string or file path for the eval case")
    parser.add_argument("--skill-description", default="", help="Skill description for LLM judge")
    parser.add_argument("--judge-runner", default="skip", help="Runner for LLM judge (auto/claude-code/api/skip)")
    args = parser.parse_args()

    output = Path(args.output_file).read_text()

    if os.path.isfile(args.case_json):
        case = json.loads(Path(args.case_json).read_text())
    else:
        case = json.loads(args.case_json)

    result = judge(output, case, args.skill_description, args.judge_runner)
    print(json.dumps(result, indent=2))
