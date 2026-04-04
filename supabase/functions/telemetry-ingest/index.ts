// Supabase Edge Function: telemetry-ingest
// Receives anonymous telemetry events from agent-skills installations.
// POST /telemetry-ingest

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.4";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;

const MAX_BATCH_SIZE = 50;
const MAX_STRING_LENGTH = 200;
const VALID_EVENTS = ["skill.run", "skill.install", "skill.uninstall", "skill.eval"];

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

function truncate(val: unknown, maxLen: number): string | null {
  if (typeof val !== "string") return null;
  return val.slice(0, maxLen);
}

function toInt(val: unknown, fallback = 0): number {
  const n = Number(val);
  return Number.isFinite(n) ? Math.max(0, Math.floor(n)) : fallback;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "POST only" }), {
      status: 405,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  try {
    const body = await req.json();
    const rawEvents = Array.isArray(body) ? body : [body];

    if (rawEvents.length > MAX_BATCH_SIZE) {
      return new Response(
        JSON.stringify({ error: `Batch too large (max ${MAX_BATCH_SIZE})` }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

    const eventRows: any[] = [];
    const installRows: any[] = [];

    for (const e of rawEvents) {
      if (typeof e !== "object" || e === null) continue;

      const event = truncate(e.event, MAX_STRING_LENGTH);

      if (event === "skill.install") {
        installRows.push({
          version: truncate(e.version, 20),
          harness: truncate(e.harness, 50),
        });
        continue;
      }

      if (!event || !VALID_EVENTS.includes(event)) continue;

      eventRows.push({
        event,
        skill: truncate(e.skill, MAX_STRING_LENGTH) || "unknown",
        version: truncate(e.version, 20),
        harness: truncate(e.harness, 50),
        category: truncate(e.outcome?.category, MAX_STRING_LENGTH),
        input_length: toInt(e.outcome?.input_length),
        output_length: toInt(e.outcome?.output_length),
        signals_detected: toInt(e.outcome?.signals_detected),
        duration_seconds: Number.isFinite(Number(e.outcome?.duration_seconds))
          ? Number(e.outcome.duration_seconds)
          : null,
        session_id: truncate(e.session_id, 20),
      });
    }

    const errors: string[] = [];

    if (eventRows.length > 0) {
      const { error } = await supabase.from("telemetry_events").insert(eventRows);
      if (error) errors.push("Failed to insert events");
    }

    if (installRows.length > 0) {
      const { error } = await supabase.from("install_events").insert(installRows);
      if (error) errors.push("Failed to insert install events");
    }

    return new Response(
      JSON.stringify({
        ok: errors.length === 0,
        accepted: eventRows.length + installRows.length,
        errors: errors.length > 0 ? errors : undefined,
      }),
      {
        status: errors.length > 0 ? 207 : 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch {
    return new Response(
      JSON.stringify({ error: "Invalid request body" }),
      { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
