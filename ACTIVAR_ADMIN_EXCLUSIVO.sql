-- Ejecuta este archivo en SQL Editor de TU proyecto Supabase de Quimiqu.
-- Primero registra e inicia sesión con tu cuenta definitiva.
-- Authentication > Users: copia el UUID (User UID) de TU cuenta.
-- Sustituye REEMPLAZAR_CON_TU_UUID en ambas líneas antes de ejecutarlo.
-- Este script nunca usa correos, contraseñas ni se ejecuta desde el navegador.

begin;
insert into public.quimiqu_admin_owner (singleton, user_id)
values (true, 'REEMPLAZAR_CON_TU_UUID'::uuid);
-- Se rechaza una segunda asignación: no reemplaza silenciosamente al dueño.
update public.quimiqu_profiles
set role = 'admin'
where id = 'REEMPLAZAR_CON_TU_UUID'::uuid;
-- Se aborta si el perfil no existe o el dueño no queda asignado.
do $$
begin
 if (select count(*) from public.quimiqu_profiles where role = 'admin') <> 1 then
  raise exception 'Falta el perfil del administrador: registra primero tu cuenta';
 end if;
end $$;
commit;
