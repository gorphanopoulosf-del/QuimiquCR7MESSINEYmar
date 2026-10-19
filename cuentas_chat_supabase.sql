-- Ejecutar en SQL Editor de un proyecto Supabase NUEVO para Quimiqu.
create table if not exists public.quimiqu_profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 display_name text check (char_length(display_name) between 2 and 25),
 role text not null default 'common' check (role in ('common','member','boss','admin')),
 created_at timestamptz not null default now()
);
create table if not exists public.quimiqu_messages (
 id bigint generated always as identity primary key,
 user_id uuid not null references auth.users(id) on delete cascade,
 display_name text not null,
 role text not null,
 body text not null check (char_length(btrim(body)) between 1 and 500),
 created_at timestamptz not null default now()
);
alter table public.quimiqu_profiles enable row level security;
alter table public.quimiqu_messages enable row level security;
drop policy if exists "profiles read" on public.quimiqu_profiles;
create policy "profiles read" on public.quimiqu_profiles for select to authenticated using (true);
drop policy if exists "profiles update own name" on public.quimiqu_profiles;
create policy "profiles update own name" on public.quimiqu_profiles for update to authenticated using (id=auth.uid()) with check (id=auth.uid());
-- Evitar elevación de privilegios: restringir columnas actualizables al nombre.
revoke all on public.quimiqu_profiles from public, anon, authenticated;
grant select on public.quimiqu_profiles to authenticated;
grant update (display_name) on public.quimiqu_profiles to authenticated;
drop policy if exists "messages read" on public.quimiqu_messages;
create policy "messages read" on public.quimiqu_messages for select to authenticated using (true);
drop policy if exists "messages insert own" on public.quimiqu_messages;
create policy "messages insert own" on public.quimiqu_messages for insert to authenticated with check (user_id=auth.uid());
grant select,insert on public.quimiqu_messages to authenticated;
create or replace function public.quimiqu_new_profile() returns trigger language plpgsql security definer set search_path='' as $$
begin insert into public.quimiqu_profiles(id,role) values(new.id,'common');return new;end $$;
drop trigger if exists quimiqu_profile_created on auth.users;
create trigger quimiqu_profile_created after insert on auth.users for each row execute function public.quimiqu_new_profile();
create or replace function public.quimiqu_message_identity() returns trigger language plpgsql security definer set search_path='' as $$
declare p record;
begin
 if new.user_id <> auth.uid() then raise exception 'Invalid user';end if;
 select display_name,role into p from public.quimiqu_profiles where id=auth.uid();
 if p.display_name is null then raise exception 'Debes configurar tu nombre';end if;
 new.display_name:=p.display_name;new.role:=p.role;
 return new;
end $$;
drop trigger if exists quimiqu_message_before_insert on public.quimiqu_messages;
create trigger quimiqu_message_before_insert before insert on public.quimiqu_messages for each row execute function public.quimiqu_message_identity();
-- Configuración exclusiva del propietario: solo un usuario autorizado puede ser admin.
-- La tabla no tiene políticas de acceso desde navegadores.
create table if not exists public.quimiqu_admin_owner (
 singleton boolean primary key default true check (singleton = true),
 user_id uuid not null unique references auth.users(id) on delete restrict
);
alter table public.quimiqu_admin_owner enable row level security;
revoke all on public.quimiqu_admin_owner from public, anon, authenticated;
-- Máximo una persona con rol admin, incluso si se intentan múltiples asignaciones.
create unique index if not exists quimiqu_one_page_admin
 on public.quimiqu_profiles ((role)) where role = 'admin';

-- Validación en el servidor: nunca confiar en los rangos enviados desde el navegador.
create or replace function public.quimiqu_check_admin_owner()
returns trigger language plpgsql security definer set search_path = '' as $$
declare approved_owner uuid;
begin
 if new.role = 'admin' then
  select user_id into approved_owner from public.quimiqu_admin_owner where singleton = true;
  if approved_owner is null or new.id is distinct from approved_owner then
   raise exception 'El rango Admin de Página está reservado al propietario autorizado';
  end if;
 end if;
 return new;
end $$;
revoke all on function public.quimiqu_check_admin_owner() from public, anon, authenticated;
drop trigger if exists quimiqu_only_owner_can_be_admin on public.quimiqu_profiles;
create trigger quimiqu_only_owner_can_be_admin
 before insert or update on public.quimiqu_profiles
 for each row execute function public.quimiqu_check_admin_owner();

-- IMPORTANTE: registrar primero TU cuenta y después ejecutar ACTIVAR_ADMIN_EXCLUSIVO.sql
-- desde SQL Editor (solo personal autorizado). Ningún usuario puede autopromoverse.

-- Para Realtime, activar la tabla quimiqu_messages en Database > Publications > supabase_realtime.
