-- Ejecutar despues de cuentas_chat_supabase.sql.
-- Identificador numerico publico, unico y permanente para cada cuenta.
create sequence if not exists public.quimiqu_user_number_seq start 1001;
alter table public.quimiqu_profiles add column if not exists user_number bigint;
update public.quimiqu_profiles set user_number=nextval('public.quimiqu_user_number_seq') where user_number is null;
alter table public.quimiqu_profiles alter column user_number set default nextval('public.quimiqu_user_number_seq');
alter table public.quimiqu_profiles alter column user_number set not null;
create unique index if not exists quimiqu_profiles_user_number_unique on public.quimiqu_profiles(user_number);
revoke update on public.quimiqu_profiles from authenticated;
grant update (display_name) on public.quimiqu_profiles to authenticated;
-- user_number no se puede modificar desde el navegador.
