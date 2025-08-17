-- =====================================================
-- CÓDIGO SQL PARA CONFIGURAR SUPABASE - mkCreativo
-- =====================================================

-- 1. CREAR TABLA DE PERFILES DE USUARIO
-- Esta tabla almacenará información adicional de los usuarios
CREATE TABLE public.user_profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'user')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. HABILITAR RLS (Row Level Security)
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- 3. CREAR POLÍTICAS DE SEGURIDAD

-- Política para que los administradores puedan ver todos los perfiles
CREATE POLICY "Admins can view all profiles" ON public.user_profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.user_profiles 
            WHERE id = auth.uid() 
            AND role = 'admin'
        ) OR 
        auth.jwt() ->> 'email' = 'saludablebela@gmail.com'
    );

-- Política para que los administradores puedan actualizar todos los perfiles
CREATE POLICY "Admins can update all profiles" ON public.user_profiles
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.user_profiles 
            WHERE id = auth.uid() 
            AND role = 'admin'
        ) OR 
        auth.jwt() ->> 'email' = 'saludablebela@gmail.com'
    );

-- Política para que los administradores puedan eliminar todos los perfiles
CREATE POLICY "Admins can delete all profiles" ON public.user_profiles
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.user_profiles 
            WHERE id = auth.uid() 
            AND role = 'admin'
        ) OR 
        auth.jwt() ->> 'email' = 'saludablebela@gmail.com'
    );

-- Política para que los usuarios puedan ver su propio perfil
CREATE POLICY "Users can view own profile" ON public.user_profiles
    FOR SELECT USING (auth.uid() = id);

-- Política para que los usuarios puedan actualizar su propio perfil
CREATE POLICY "Users can update own profile" ON public.user_profiles
    FOR UPDATE USING (auth.uid() = id);

-- Política para que los usuarios autenticados puedan insertar su perfil
CREATE POLICY "Enable insert for authenticated users" ON public.user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- 4. CREAR FUNCIÓN PARA AUTO-CREAR PERFIL AL REGISTRARSE
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (id, full_name, role)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'Usuario'),
        CASE 
            WHEN NEW.email = 'saludablebela@gmail.com' THEN 'admin'
            ELSE 'user'
        END
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. CREAR TRIGGER PARA EJECUTAR LA FUNCIÓN
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 6. CREAR FUNCIÓN PARA VERIFICAR SI UN USUARIO ES ADMIN
CREATE OR REPLACE FUNCTION public.is_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_profiles
        WHERE id = user_id AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. CREAR FUNCIÓN PARA OBTENER EL ROL DEL USUARIO ACTUAL
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT AS $$
BEGIN
    RETURN (
        SELECT role FROM public.user_profiles
        WHERE id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. INSERTAR MANUALMENTE EL USUARIO ADMIN (EJECUTAR DESPUÉS DEL REGISTRO)
-- NOTA: Este INSERT solo funcionará después de que el usuario saludablebela@gmail.com se registre
-- Si ya existe el usuario, actualizar su rol:
-- UPDATE public.user_profiles SET role = 'admin' WHERE id = (SELECT id FROM auth.users WHERE email = 'saludablebela@gmail.com');

-- 9. CREAR VISTA PARA ESTADÍSTICAS DE USUARIOS (OPCIONAL)
CREATE OR REPLACE VIEW public.user_stats AS
SELECT 
    COUNT(*) as total_users,
    COUNT(CASE WHEN role = 'admin' THEN 1 END) as admin_users,
    COUNT(CASE WHEN role = 'user' THEN 1 END) as regular_users,
    COUNT(CASE WHEN DATE(created_at) = CURRENT_DATE THEN 1 END) as users_today
FROM public.user_profiles;

-- IMPORTANTE: Configuración adicional para la página de bienvenida
-- En el Dashboard de Supabase, ve a Authentication > Settings > Email Templates
-- Y configura la URL de confirmación como: https://tu-dominio.com/bienvenido.html
-- O para desarrollo local: http://localhost:8000/bienvenido.html

-- También puedes configurar las URLs de redirección en Authentication > URL Configuration:
-- Site URL: https://tu-dominio.com (o http://localhost:8000 para desarrollo)
-- Redirect URLs: https://tu-dominio.com/bienvenido.html (o http://localhost:8000/bienvenido.html)

-- =====================================================
-- INSTRUCCIONES DE USO:
-- =====================================================
-- 1. Copia y pega este código en el Editor SQL de Supabase
-- 2. Ejecuta todo el código
-- 3. El usuario saludablebela@gmail.com será automáticamente admin al registrarse
-- 4. Todos los demás usuarios serán 'user' por defecto
-- =====================================================