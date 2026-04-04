# Deploying the Telemetry Backend

## Prerequisites

- A [Supabase](https://supabase.com) account (free tier works)
- Supabase CLI: `npm install -g supabase`

## Setup

### 1. Create a Supabase project

Go to [supabase.com/dashboard](https://supabase.com/dashboard) and create a new project. Note your:
- **Project URL**: `https://xxxxx.supabase.co`
- **Anon key**: for public access
- **Service role key**: for edge functions

### 2. Run the migration

```bash
supabase db push --db-url "postgresql://postgres:YOUR_PASSWORD@db.xxxxx.supabase.co:5432/postgres"
```

Or paste `supabase/migrations/001_telemetry.sql` into the SQL editor in the Supabase dashboard.

### 3. Deploy edge functions

```bash
cd supabase
supabase functions deploy telemetry-ingest
supabase functions deploy community-pulse
supabase functions deploy update-check
```

### 4. Set your endpoint

Your telemetry endpoint is:
```
https://xxxxx.supabase.co/functions/v1/telemetry-ingest
```

Add it to the setup script or tell users to configure it:

```json
{
  "telemetry": true,
  "telemetry_endpoint": "https://xxxxx.supabase.co/functions/v1/telemetry-ingest"
}
```

## Edge Functions

| Function | Method | What it does |
|---|---|---|
| `telemetry-ingest` | POST | Receives anonymous skill usage events |
| `community-pulse` | GET | Returns aggregate usage stats (public dashboard) |
| `update-check` | GET | Checks if new skill versions are available |

## API Examples

### Send a telemetry event

```bash
curl -X POST https://xxxxx.supabase.co/functions/v1/telemetry-ingest \
  -H "Content-Type: application/json" \
  -d '{"event":"skill.run","skill":"ai-slop-detector","version":"1.0.0","harness":"claude-code","outcome":{"category":"pure slop","input_length":300}}'
```

### Get community stats

```bash
# All skills, last 30 days
curl https://xxxxx.supabase.co/functions/v1/community-pulse

# Specific skill
curl https://xxxxx.supabase.co/functions/v1/community-pulse?skill=ai-slop-detector

# Last 7 days
curl https://xxxxx.supabase.co/functions/v1/community-pulse?days=7
```

### Check for updates

```bash
curl "https://xxxxx.supabase.co/functions/v1/update-check?version=1.1.0&skills=ai-slop-detector,create-skill"
```

## Database Tables

| Table | Purpose |
|---|---|
| `telemetry_events` | Raw skill invocation events |
| `telemetry_daily` | Pre-aggregated daily stats |
| `install_events` | Installation tracking |

## Row Level Security

- **Insert**: Anyone can insert events (anonymous telemetry)
- **Read aggregates**: Anyone can read `telemetry_daily` (public dashboard)
- **Raw events**: Only service role can read (admin only)

## Cost

Supabase free tier includes:
- 500MB database
- 2M edge function invocations/month
- 1GB egress

This is more than enough for a growing skills marketplace.
