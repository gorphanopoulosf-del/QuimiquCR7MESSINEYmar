# Quimiqu: cuentas, rangos, chat y música
La música instrumental original se activa con el botón ♫ en cada página (los navegadores exigen un clic).
Para activar usuarios y chat compartido:
1. Crea un proyecto Supabase exclusivo para Quimiqu.
2. Ejecuta `cuentas_chat_supabase.sql` en SQL Editor.
3. En Authentication > Providers activa Email y los proveedores OAuth Google, GitHub y Facebook deseados, configurando sus credenciales y URL de retorno según Supabase.
4. En Authentication > URL Configuration añade la URL definitiva https://TU_USUARIO.github.io/NOMBRE_DEL_REPOSITORIO y el redirect https://TU_USUARIO.github.io/NOMBRE_DEL_REPOSITORIO/chat.html.
5. En `config.js` escribe únicamente Project URL y clave pública `anon`/publishable (NUNCA service_role ni contraseñas).
6. Publica la carpeta mediante GitHub Pages, y activa Realtime para `quimiqu_messages`.
7. Registra tu cuenta personal en el sitio (o mediante Authentication > Users) y copia tu **User UID** desde Supabase > Authentication > Users.
8. En el SQL Editor abre `ACTIVAR_ADMIN_EXCLUSIVO.sql`, reemplaza `REEMPLAZAR_CON_TU_UUID` en sus dos apariciones por tu UUID y ejecútalo una sola vez.
9. El servidor aplica dos barreras: solo el UUID del propietario autorizado puede recibir `admin` y solo puede existir un administrador de página. Los usuarios normales no pueden cambiar su rango, aunque manipulen el navegador.
10. El UUID del propietario no se incluye en el HTML ni en los archivos públicos. No publiques el archivo `ACTIVAR_ADMIN_EXCLUSIVO.sql` como una ruta web tras configurarlo; mantenlo como material de instalación.
Los usuarios registrados se almacenan en Supabase Auth y quimiqu_profiles. No se muestran correos ni contraseñas de otros usuarios en la página. La vista de usuarios puede consultarse por administradores en el panel Supabase.
Sin completar estos pasos, el registro, los inicios de sesión y el chat compartido permanecen deshabilitados. La votación pública también necesita su configuración de backend independiente.

**Importante:** el administrador exclusivo todavía no está asignado hasta registrar tu cuenta y ejecutar el SQL de activación. No se ha conectado ni modificado ninguna base de datos real.

## Chats privados
Ejecuta `CHATS_PRIVADOS_SUPABASE.sql` en el mismo proyecto Supabase. Activa Realtime para `quimiqu_private_messages`. Los mensajes privados estan protegidos con politicas RLS: solo emisor y destinatario pueden leerlos. No es cifrado de extremo a extremo; el administrador de la base de datos puede acceder a ellos.

## Numero identificador
Ejecuta `IDENTIFICADORES_SUPABASE.sql` despues del esquema de cuentas. Los IDs empiezan en #1001, son unicos, permanentes y no se pueden cambiar desde la web.

## Identificador personalizado
Ejecuta `IDENTIFICADOR_ELEGIDO_SUPABASE.sql` al final. El nombre visible es libre y puede repetirse. Cada persona elige un identificador de 3 a 24 caracteres (letras, numeros y guion bajo), unico sin importar mayusculas. Si esta ocupado, la base de datos rechaza el cambio. Los IDs numericos anteriores se conservan internamente.
