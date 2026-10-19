# Publicación de Quimiqu

1. Crear un proyecto Supabase NUEVO dedicado a Quimiqu y ejecutar `supabase.sql` en su editor SQL.
2. Desplegar esta carpeta en Vercel como proyecto `quimiqu`, framework Other.
3. Configurar en Vercel las variables de servidor `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` (secreta) y `VOTE_SECRET` (32+ bytes aleatorios).
4. Volver a desplegar y verificar GET `/api/votes` y un POST de prueba. La clave service_role nunca debe ser pública.

Protección: un voto por cookie de navegador almacenada con hash HMAC en la base de datos. No previene que alguien borre cookies o utilice navegadores distintos. Si se requiere votación resistente al fraude, incorporar autenticación y limitación de tasa/abuso.
