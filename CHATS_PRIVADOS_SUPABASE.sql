
-- CHATS PRIVADOS DE QUIMIQU: ejecutar DESPUÉS de cuentas_chat_supabase.sql.
-- Solo los dos participantes pueden ver la conversación.
create table if not exists public.quimiqu_private_messages (
 id bigint generated always as identity primary key,
 sender_id uuid not null references auth.users(id) on delete cascade,
 recipient_id uuid not null references auth.users(id) on delete cascade,
 body text not null check (char_length(btrim(body)) between 1 and 500),
 created_at timestamptz not null default now(),
 constraint quimiqu_private_not_self check (sender_id <> recipient_id)
);
alter table public.quimiqu_private_messages enable row level security;
drop policy if exists "private read participants" on public.quimiqu_private_messages;
create policy "private read participants" on public.quimiqu_private_messages for select to authenticated
 using (auth.uid() = sender_id or auth.uid() = recipient_id);
drop policy if exists "private send own" on public.quimiqu_private_messages;
create policy "private send own" on public.quimiqu_private_messages for insert to authenticated
 with check (auth.uid() = sender_id and exists (
 select 1 from public.quimiqu_profiles p where p.id=recipient_id and p.display_name is not null
 ));
revoke all on public.quimiqu_private_messages from anon;
grant select,insert on public.quimiqu_private_messages to authenticated;
-- Los perfiles se pueden consultar para encontrar otros usuarios por su nombre público.
-- No se publican correos electrónicos ni contraseñas.
-- Activar Realtime para quimiqu_private_messages en Supabase Database > Publications.
