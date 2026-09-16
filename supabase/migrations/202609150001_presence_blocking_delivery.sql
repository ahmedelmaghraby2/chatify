-- Presence, blocked users, and message delivery states.

create table if not exists public.user_presence (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  is_online boolean not null default false,
  last_seen_at timestamptz,
  online_at timestamptz
);
alter table public.user_presence enable row level security;
create policy "presence readable" on public.user_presence for select to authenticated using(true);
create policy "presence self upsert" on public.user_presence for insert to authenticated with check(user_id=auth.uid());
create policy "presence self update" on public.user_presence for update to authenticated using(user_id=auth.uid());

create table if not exists public.blocked_users (
  user_id uuid not null references public.profiles(id) on delete cascade,
  blocked_user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(user_id, blocked_user_id)
);
alter table public.blocked_users enable row level security;
create policy "self blocked rows" on public.blocked_users for all to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid());

alter table public.messages add column if not exists status text default 'sent' check (status in ('sent','delivered','seen','failed'));
alter table public.messages add column if not exists media_url text;

alter publication supabase_realtime add table public.user_presence;