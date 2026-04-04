// Supabase Edge Function: community-pulse
// Public dashboard API — returns aggregate usage stats.
// GET /community-pulse
// GET /community-pulse?skill=ai-slop-detector
// GET /community-pulse?days=30

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  if (req.method !== "GET") {
    return new Response(JSON.stringify({ error: "GET only" }), {
      status: 405,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const url = new URL(req.url);
  const skillFilter = url.searchParams.get("skill");
  const days = parseInt(url.searchParams.get("days") || "30");

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

  const since = new Date();
  since.setDate(since.getDate() - days);
  const sinceStr = since.toISOString();

  // Run all independent queries in parallel
  let categoryQuery = supabase
    .from("telemetry_events")
    .select("skill, category, created_at, session_id")
    .gte("created_at", sinceStr);

  if (skillFilter) {
    categoryQuery = categoryQuery.eq("skill", skillFilter);
  }

  const [eventsResult, installResult] = await Promise.all([
    categoryQuery,
    supabase
      .from("install_events")
      .select("*", { count: "exact", head: true }),
  ]);

  const rows = eventsResult.data || [];

  // Aggregate in a single pass over the data
  const skillCounts: Record<string, number> = {};
  const categories: Record<string, Record<string, number>> = {};
  const dailyCounts: Record<string, number> = {};
  const sessionIds = new Set<string>();

  for (const row of rows) {
    // Skill counts
    skillCounts[row.skill] = (skillCounts[row.skill] || 0) + 1;

    // Category breakdown
    if (row.category) {
      if (!categories[row.skill]) categories[row.skill] = {};
      categories[row.skill][row.category] =
        (categories[row.skill][row.category] || 0) + 1;
    }

    // Daily trend
    const day = row.created_at.substring(0, 10);
    dailyCounts[day] = (dailyCounts[day] || 0) + 1;

    // Unique sessions
    if (row.session_id) {
      sessionIds.add(row.session_id);
    }
  }

  const response = {
    period_days: days,
    total_installs: installResult.count || 0,
    total_runs: Object.values(skillCounts).reduce((a, b) => a + b, 0),
    unique_sessions: sessionIds.size,
    skills: Object.entries(skillCounts)
      .map(([skill, count]) => ({
        skill,
        runs: count,
        categories: categories[skill] || {},
      }))
      .sort((a, b) => b.runs - a.runs),
    daily_trend: Object.entries(dailyCounts)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([date, count]) => ({ date, runs: count })),
  };

  return new Response(JSON.stringify(response, null, 2), {
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
});
