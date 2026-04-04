// Supabase Edge Function: telemetry-ingest
// Receives anonymous telemetry events from agent-skills installations.
// POST /telemetry-ingest
//
// Body: single event or array of events
// {
//   "event": "skill.run",
//   "skill": "ai-slop-detector",
//   "version": "1.0.0",
//   "timestamp": "2026-04-04T12:00:00Z",
//   "harness": "claude-code",
//   "outcome": { "category": "pure slop", "input_length": 300, "output_length": 500, "signals_detected": 3 },
//   "session_id": "a1b2c3d4"
// }

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

Deno.serve(async (req) => {
  // CORS preflight
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
    const events = Array.isArray(body) ? body : [body];

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

    const rows = events.map((e: any) => {
      // Handle install events separately
      if (e.event === "skill.install") {
        return {
          table: "install_events",
          row: {
            version: e.version || null,
            harness: e.harness || null,
          },
        };
      }

      return {
        table: "telemetry_events",
        row: {
          event: e.event || "skill.run",
          skill: e.skill || "unknown",
          version: e.version || null,
          harness: e.harness || null,
          category: e.outcome?.category || null,
          input_length: e.outcome?.input_length || 0,
          output_length: e.outcome?.output_length || 0,
          signals_detected: e.outcome?.signals_detected || 0,
          duration_seconds: e.outcome?.duration_seconds || null,
          session_id: e.session_id || null,
        },
      };
    });

    // Batch insert by table
    const eventRows = rows
      .filter((r: any) => r.table === "telemetry_events")
      .map((r: any) => r.row);
    const installRows = rows
      .filter((r: any) => r.table === "install_events")
      .map((r: any) => r.row);

    const results = [];

    if (eventRows.length > 0) {
      const { error } = await supabase
        .from("telemetry_events")
        .insert(eventRows);
      if (error) results.push({ table: "telemetry_events", error: error.message });
    }

    if (installRows.length > 0) {
      const { error } = await supabase
        .from("install_events")
        .insert(installRows);
      if (error) results.push({ table: "install_events", error: error.message });
    }

    const hasErrors = results.some((r: any) => r.error);

    return new Response(
      JSON.stringify({
        ok: !hasErrors,
        accepted: events.length,
        errors: hasErrors ? results : undefined,
      }),
      {
        status: hasErrors ? 207 : 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: "Invalid request body" }),
      {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
