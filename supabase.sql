-- Ejecutar exclusivamente en un proyecto Supabase nuevo dedicado a Quimiqu.
create table if not exists public.quimiqu_votes (
  voter_hash text primary key check (voter_hash ~ '^[a-f0-9]{64}$'),
  player text not null check (player in ('messi','ronaldo','neymar')),
  created_at timestamptz not null default now()
);
alter table public.quimiqu_votes enable row level security;
revoke all on public.quimiqu_votes from anon, authenticated;
create or replace view public.quimiqu_vote_totals with (security_invoker = false) as
select player, count(*)::bigint as total from public.quimiqu_votes group by player;
revoke all on public.quimiqu_vote_totals from anon, authenticated;
-- La API se conecta únicamente mediante la clave service_role almacenada en el servidor.
