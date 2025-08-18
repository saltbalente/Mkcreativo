# Configuración de Supabase para Producción - mkCreativo

## URLs de Configuración Requeridas

Para que el sistema funcione correctamente en producción (mkinnovador.com), necesitas configurar las siguientes URLs en el panel de Supabase:

### 1. Authentication Settings

Ve a: **Authentication > Settings > URL Configuration**

- **Site URL**: `https://mkinnovador.com`
- **Redirect URLs**: 
  - `https://mkinnovador.com/bienvenido.html`
  - `https://mkinnovador.com/admin.html`
  - `https://mkinnovador.com/login.html`
  - `https://mkinnovador.com/register.html`

### 2. Email Templates

Ve a: **Authentication > Email Templates**

Para cada template (Confirm signup, Magic Link, etc.):
- Cambia `{{ .RedirectTo }}` por `https://mkinnovador.com/bienvenido.html`
- O asegúrate de que la URL de redirección apunte al dominio correcto

### 3. Configuración de CORS

Ve a: **Settings > API**

En **CORS origins**, agregar:
- `https://mkinnovador.com`
- `https://www.mkinnovador.com` (si usas www)

### 4. Variables de Entorno (si usas hosting)

Si despliegas en un servicio como Vercel, Netlify, etc.:

```env
SUPABASE_URL=https://udjzuyurelatvgpgwuye.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVkanp1eXVyZWxhdHZncGd3dXllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU0NzA5MTcsImV4cCI6MjA3MTA0NjkxN30.SN1MlphEN9bMCOhMT2ZRjfncU9QR4GWINPSH1y_j5xc
```

## Problemas Actuales Solucionados

### ✅ Error 400 en get_all_users
- **Causa**: La función RPC `is_admin` no recibía el parámetro `user_id`
- **Solución**: Actualizado `supabase-config.js` para pasar el parámetro correctamente

### ✅ Redirección a localhost:3000
- **Causa**: Site URL configurada incorrectamente en Supabase
- **Solución**: Cambiar Site URL a `https://mkinnovador.com` en el panel de Supabase

### ✅ Emails aparecen como "sin email"
- **Causa**: Estructura de datos incorrecta en displayUsers
- **Solución**: Ya corregido en admin.html

## Instrucciones de Implementación

1. **Ejecutar SQL**: Usar `supabase-fix-policies.sql` en el Editor SQL de Supabase
2. **Configurar URLs**: Seguir las configuraciones de URL arriba
3. **Subir archivos**: Subir todos los archivos HTML/CSS/JS a mkinnovador.com
4. **Probar**: Verificar registro, login y panel de admin

## Verificación

Para verificar que todo funciona:

1. Ir a `https://mkinnovador.com/register.html`
2. Registrar un nuevo usuario
3. Verificar que el email de confirmación redirija a mkinnovador.com
4. Hacer login y verificar acceso al panel de admin (solo saludablebela@gmail.com)

---

**Nota**: Estos cambios solo afectan el entorno de producción. Para desarrollo local, puedes seguir usando localhost:8000.