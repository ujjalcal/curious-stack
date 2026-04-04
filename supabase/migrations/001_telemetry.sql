-- Telemetry tables for curious-stack usage tracking
-- All data is anonymous — no PII, no input/output text

-- Raw events from skill invocations
create table if not exists telemetry_events (
  id bigint generated always as identity primary key,
  event text not null check (event in ('skill.run', 'skill.install', 'skill.uninstall', 'skill.eval')),
  skill text not null,
  version text,
  harness text,
  category text,              -- verdict/outcome category (e.g., "pure slop", "pass")
  input_length int default 0,
  output_length int default 0,
  signals_detected int default 0,
  duration_seconds numeric,
  session_id text,            -- random per-session, not tied to user
  created_at timestamptz default now()
);

-- Indexes for common queries
create index if not exists idx_events_skill on telemetry_events (skill);
create index if not exists idx_events_created on telemetry_events (created_at);
create index if not exists idx_events_skill_created on telemetry_events (skill, created_at);

-- Daily aggregates (materialized by edge function or cron)
create table if not exists telemetry_daily (
  id bigint generated always as identity primary key,
  date date not null,
  skill text not null,
  total_runs int default 0,
  categories jsonb default '{}',    -- {"pure slop": 5, "clean": 3, ...}
  avg_input_length numeric default 0,
  avg_signals numeric default 0,
  unique_sessions int default 0,
  unique (date, skill)
);

create index if not exists idx_daily_date on telemetry_daily (date);
create index if not exists idx_daily_skill on telemetry_daily (skill);

-- Install counts
create table if not exists install_events (
  id bigint generated always as identity primary key,
  version text,
  harness text,
  created_at timestamptz default now()
);

-- Row Level Security: allow inserts from anon, reads from authenticated or service role
alter table telemetry_events enable row level security;
alter table telemetry_daily enable row level security;
alter table install_events enable row level security;

-- Anyone can insert (anonymous telemetry)
create policy "anon_insert_events" on telemetry_events for insert to anon with check (true);
create policy "anon_insert_installs" on install_events for insert to anon with check (true);

-- Anyone can read aggregates (public dashboard)
create policy "anon_read_daily" on telemetry_daily for select to anon using (true);

-- Service role can do everything
create policy "service_all_events" on telemetry_events for all to service_role using (true) with check (true);
create policy "service_all_daily" on telemetry_daily for all to service_role using (true) with check (true);
create policy "service_all_installs" on install_events for all to service_role using (true) with check (true);
