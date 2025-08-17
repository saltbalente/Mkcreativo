# mkCreativo - Plataforma de Marketing Digital

## 🚀 Descripción

mkCreativo es una plataforma web moderna para servicios de marketing digital que incluye un sistema completo de autenticación de usuarios, panel de administración y páginas de bienvenida personalizadas.

## ✨ Características

### 🔐 Sistema de Autenticación
- **Registro de usuarios** con validación de email
- **Inicio de sesión seguro** con Supabase Auth
- **Confirmación por email** con redirección automática
- **Sistema de roles** (Admin/Usuario)
- **Protección de rutas** basada en roles
- **Página de bienvenida** personalizada post-registro

### 👑 Panel de Administración
- **Dashboard administrativo** con estadísticas de usuarios
- **Gestión de usuarios** (editar/eliminar)
- **Vista de usuarios** con filtros y búsqueda
- **Acceso restringido** solo para administradores

### 🎨 Diseño y UX
- **Diseño responsivo** para móviles y escritorio
- **Interfaz moderna** con gradientes y animaciones
- **Navegación dinámica** basada en estado de autenticación
- **Mensajes de éxito/error** integrados
- **Página de políticas de privacidad** completa

## 📁 Estructura del Proyecto

```
pixelboost_landing_page/
├── index.html              # Página principal
├── login.html              # Página de inicio de sesión
├── register.html           # Página de registro
├── admin.html              # Panel de administración
├── bienvenido.html         # Página de bienvenida post-registro
├── privacy.html            # Políticas de privacidad
├── css/
│   └── style.css          # Estilos principales
├── js/
│   ├── script.js          # Funcionalidades principales
│   └── supabase-config.js # Configuración de Supabase
├── img/                   # Imágenes y recursos
├── supabase-setup.sql     # Script de configuración de BD
└── README.md              # Documentación
```

## 🛠️ Tecnologías Utilizadas

- **Frontend**: HTML5, CSS3, JavaScript (Vanilla)
- **Backend**: Supabase (Auth, Database, RLS)
- **Base de Datos**: PostgreSQL (via Supabase)
- **Autenticación**: Supabase Auth
- **Hosting**: Compatible con cualquier servidor web estático

## ⚙️ Configuración

### 1. Configurar Supabase

1. Crea un proyecto en [Supabase](https://supabase.com)
2. Ejecuta el script `supabase-setup.sql` en el Editor SQL
3. Configura las variables en `js/supabase-config.js`:

```javascript
const SUPABASE_URL = 'tu-proyecto-url.supabase.co';
const SUPABASE_ANON_KEY = 'tu-anon-key';
```

### 2. Configurar URLs de Redirección

En el Dashboard de Supabase:

**Authentication > URL Configuration:**
- Site URL: `https://tu-dominio.com`
- Redirect URLs: `https://tu-dominio.com/bienvenido.html`

**Authentication > Email Templates:**
- Confirm signup: `https://tu-dominio.com/bienvenido.html`

### 3. Usuario Administrador

El sistema está configurado para asignar automáticamente el rol de administrador a:
- **Email**: `saludablebela@gmail.com`

Todos los demás usuarios serán usuarios regulares por defecto.

## 🚀 Instalación y Uso

### Desarrollo Local

1. Clona el repositorio:
```bash
git clone https://github.com/tu-usuario/mkcreativo.git
cd mkcreativo
```

2. Inicia un servidor local:
```bash
python3 -m http.server 8000
# o
npx serve .
```

3. Abre tu navegador en `http://localhost:8000`

### Producción

1. Sube los archivos a tu servidor web
2. Configura las URLs de Supabase para producción
3. Actualiza las URLs de redirección en Supabase

## 📊 Base de Datos

### Tablas Principales

- **`auth.users`**: Usuarios de Supabase (automática)
- **`user_profiles`**: Perfiles extendidos con roles

### Políticas de Seguridad (RLS)

- Los usuarios solo pueden ver/editar su propio perfil
- Los administradores pueden gestionar todos los usuarios
- Políticas automáticas para protección de datos

## 🔒 Seguridad

- **Row Level Security (RLS)** habilitado
- **Validación de email/contraseña** en frontend y backend
- **Protección de rutas administrativas**
- **Tokens JWT** seguros para autenticación
- **Verificación de roles** en tiempo real

## 🎯 Funcionalidades Principales

### Para Usuarios
- ✅ Registro con confirmación por email
- ✅ Inicio de sesión seguro
- ✅ Página de bienvenida personalizada
- ✅ Navegación dinámica
- ✅ Cierre de sesión

### Para Administradores
- ✅ Panel de administración completo
- ✅ Estadísticas de usuarios
- ✅ Gestión de usuarios (editar/eliminar)
- ✅ Filtros y búsqueda de usuarios
- ✅ Acceso restringido por roles

## 🌐 URLs del Sitio

- `/` - Página principal
- `/login.html` - Inicio de sesión
- `/register.html` - Registro de usuarios
- `/admin.html` - Panel de administración (solo admins)
- `/bienvenido.html` - Página de bienvenida
- `/privacy.html` - Políticas de privacidad

## 📝 Notas de Desarrollo

- El proyecto usa **Vanilla JavaScript** para máxima compatibilidad
- **Supabase** maneja toda la lógica de backend
- **CSS Grid/Flexbox** para layouts responsivos
- **Animaciones CSS** para mejor UX
- **Políticas de privacidad** conformes a normativas colombianas

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 📞 Contacto

**mkCreativo** - Marketing Digital
- Email: saludablebela@gmail.com
- Website: [mkcreativo.com](https://mkcreativo.com)

---

⭐ **¡No olvides dar una estrella al proyecto si te fue útil!**