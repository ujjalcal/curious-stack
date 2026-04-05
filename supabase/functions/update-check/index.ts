// Supabase Edge Function: update-check
// Called by /upgrade-skills to check if new versions are available.
// GET /update-check?version=1.1.0
//
// Returns: { "latest": "1.2.0", "has_update": true, "new_skills": ["new-skill-name"] }

const REGISTRY_URLS = [
  "https://raw.githubusercontent.com/ujjalcal/curious-stack/main/registry.json",
];

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
  const currentVersion = url.searchParams.get("version") || "0.0.0";
  const installedSkills = (url.searchParams.get("skills") || "")
    .split(",")
    .filter(Boolean);

  try {
    let registry = null;
    for (const url of REGISTRY_URLS) {
      const resp = await fetch(url);
      if (resp.ok) {
        registry = await resp.json();
        break;
      }
    }

    if (!registry) {
      return new Response(
        JSON.stringify({ error: "Could not fetch registry" }),
        {
          status: 502,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }
    const latestVersion = registry.version || "0.0.0";
    const registrySkills = (registry.skills || []).map(
      (s: any) => s.name
    );

    // Find new skills not in user's installed list
    const newSkills = registrySkills.filter(
      (s: string) => !installedSkills.includes(s)
    );

    // Semver compare: split into [major, minor, patch] and compare numerically
    const parseSemver = (v: string) => v.split(".").map(Number);
    const [lMaj, lMin, lPat] = parseSemver(latestVersion);
    const [cMaj, cMin, cPat] = parseSemver(currentVersion);
    const hasUpdate =
      lMaj > cMaj ||
      (lMaj === cMaj && lMin > cMin) ||
      (lMaj === cMaj && lMin === cMin && lPat > cPat);

    return new Response(
      JSON.stringify({
        latest: latestVersion,
        current: currentVersion,
        has_update: hasUpdate,
        new_skills: newSkills,
        total_skills: registrySkills.length,
      }),
      {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
          "Cache-Control": "public, max-age=300",
        },
      }
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: "Failed to check for updates" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
