-- Ejecutar DESPUÉS de cuentas_chat_supabase.sql y de IDENTIFICADORES_SUPABASE.sql.
-- Identificador elegido por la persona, único sin distinguir mayúsculas.
alter table public.quimiqu_profiles add column if not exists handle text;
alter table public.quimiqu_profiles drop constraint if exists quimiqu_handle_format;
alter table public.quimiqu_profiles add constraint quimiqu_handle_format
  check (handle is null or (char_length(handle) between 3 and 24 and handle ~ '^[a-zA-Z0-9_]+$'));
create unique index if not exists quimiqu_profiles_handle_unique
  on public.quimiqu_profiles (lower(handle));
-- Cada usuario solo puede actualizar su nombre y su identificador.
revoke update on public.quimiqu_profiles from authenticated;
grant update (display_name,handle) on public.quimiqu_profiles to authenticated;
-- El número interno se conserva para la base de datos, pero el público es el handle.
-- La unicidad está garantizada por PostgreSQL, también ante registros simultáneos.
