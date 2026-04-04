# TODO

## In Progress

- Fix 12 validation warnings: description drift between SKILL.md frontmatter, manifest.json, and registry.json across 5 skills
- Add evals (samples.json) for 5 skills missing them: create-skill, eval-skill, improve-skill, upgrade-skills, usage-dashboard

## Planned

- **Skill templates (.tmpl)** — Generate SKILL.md from templates instead of hand-writing. Enables injecting shared content (preamble, telemetry, formatting) automatically. See how gstack uses `SKILL.md.tmpl` + `bun run gen:skill-docs`.
- **Shared preamble/ethos injection** — Common principles injected into every skill's preamble automatically. Ensures consistent tone, behavior, and quality bar without copy-pasting.
- **Operational learnings (per-project JSONL)** — After each skill session, log what went wrong (CLI errors, wrong approaches, project quirks) to `~/.curious-stack/projects/{slug}/learnings.jsonl`. Future skill runs consult this file. Skills get smarter on your codebase over time.

## Done (this session)

- [x] Telemetry through infra, not skills — opt-in consent on first run, default off
- [x] Static validation of SKILL.md internals — frontmatter/manifest/registry consistency, referenced file checks, inline telemetry detection
- [x] Dev mode — `bin/dev-setup` and `bin/dev-teardown` for live skill editing via symlinks
- [x] Fixed shell injection in api-generic.sh (triple-quoted string → env vars)
- [x] Fixed broken subshell variable scoping in eval.sh (counters always 0)
- [x] Fixed broken semver compare in update-check (string != → numeric)
- [x] Parallelized community-pulse queries (5 sequential → 1 + Promise.all)
- [x] Parallelized telemetry-ingest inserts (Promise.all)
- [x] Removed inline telemetry from ai-slop-detector and create-skill SKILL.md
- [x] Renamed all repo references from agent-skills to curious-stack
- [x] Updated README: install flow matches setup behavior, added uninstall section
