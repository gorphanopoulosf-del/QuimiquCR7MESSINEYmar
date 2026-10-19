# Quimiqu — página web

Este repositorio contiene la página web de **Quimiqu**.

## Enlace de la página

Una vez activado **GitHub Pages** en este repositorio, el enlace será:

`https://TU_USUARIO.github.io/NOMBRE_DEL_REPOSITORIO/`

Reemplaza `TU_USUARIO` y `NOMBRE_DEL_REPOSITORIO` por los datos reales de GitHub.

**Importante:** la dirección `https://quimiquaura67.vercel.app/` es una dirección de **Vercel**, no de GitHub Pages. No se activa por subir este proyecto a GitHub.

## Cómo activar la URL con GitHub

1. Crea o abre el repositorio de Quimiqu en tu cuenta de GitHub.
2. Sube el **contenido de este ZIP** al nivel principal del repositorio (donde está `index.html`). No subas solamente el ZIP.
3. Entra a **Settings → Pages**.
4. En **Build and deployment**, selecciona **Deploy from a branch**.
5. Elige rama **main**, carpeta **/(root)** y guarda con **Save**.
6. Cuando GitHub indique la URL publicada, cópiala a **Settings → General → Website** del repositorio, si tienes esa opción.

## Funciones que requieren servidor

GitHub Pages publica archivos estáticos. La interfaz, navegación y música están incluidas; el registro, los chats reales y los IDs únicos requieren configurar Supabase (ver `INSTALACION_CUENTAS.md`).

La votación compartida anterior utilizaba una API de Vercel. GitHub Pages **no puede ejecutar** esa API. Para que el voto se guarde entre todos los visitantes, hay que adaptar esa función a un servicio de backend, o usar el despliegue de Vercel.

**Seguridad:** nunca subas contraseñas, `service_role`, otras claves secretas ni SQL personalizado con datos privados al repositorio.
