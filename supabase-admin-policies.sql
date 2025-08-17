-- =====================================================
-- POLÍTICAS DE SEGURIDAD PARA ADMINISTRADORES
-- Configuración completa de permisos para admin
-- =====================================================

-- Primero, eliminar todas las políticas existentes
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON user_profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON user_profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON user_profiles;
DROP POLICY IF EXISTS "Admins can delete all profiles" ON user_profiles;

-- Asegurar que RLS esté habilitado
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- POLÍTICAS PARA ADMINISTRADORES (ACCESO COMPLETO)
-- =====================================================

-- Los administradores pueden ver TODOS los perfiles
CREATE POLICY "Admins can view all profiles" ON user_profiles
    FOR SELECT
    TO public
    USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            WHERE up.id = auth.uid()
            AND up.role = 'admin'
        )
        OR 
        -- También permitir si el usuario es saludablebela@gmail.com
        EXISTS (
            SELECT 1 FROM auth.users au
            WHERE au.id = auth.uid()
            AND au.email = 'saludablebela@gmail.com'
        )
    );

-- Los administradores pueden actualizar TODOS los perfiles
CREATE POLICY "Admins can update all profiles" ON user_profiles
    FOR UPDATE
    TO public
    USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            WHERE up.id = auth.uid()
            AND up.role = 'admin'
        )
        OR 
        -- También permitir si el usuario es saludablebela@gmail.com
        EXISTS (
            SELECT 1 FROM auth.users au
            WHERE au.id = auth.uid()
            AND au.email = 'saludablebela@gmail.com'
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM user_profiles up
            WHERE up.id = auth.uid()
            AND up.role = 'admin'
        )
        OR 
        EXISTS (
            SELECT 1 FROM auth.users au
            WHERE au.id = auth.uid()
            AND au.email = 'saludablebela@gmail.com'
        )
    );

-- Los administradores pueden eliminar TODOS los perfiles
CREATE POLICY "Admins can delete all profiles" ON user_profiles
    FOR DELETE
    TO public
    USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            WHERE up.id = auth.uid()
            AND up.role = 'admin'
        )
        OR 
        EXISTS (
            SELECT 1 FROM auth.users au
            WHERE au.id = auth.uid()
            AND au.email = 'saludablebela@gmail.com'
        )
    );

-- Los administradores pueden insertar nuevos perfiles
CREATE POLICY "Admins can insert profiles" ON user_profiles
    FOR INSERT
    TO public
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM user_profiles up
            WHERE up.id = auth.uid()
            AND up.role = 'admin'
        )
        OR 
        EXISTS (
            SELECT 1 FROM auth.users au
            WHERE au.id = auth.uid()
            AND au.email = 'saludablebela@gmail.com'
        )
        OR
        -- Permitir que los usuarios creen su propio perfil
        auth.uid() = id
    );

-- =====================================================
-- POLÍTICAS PARA USUARIOS REGULARES (ACCESO LIMITADO)
-- =====================================================

-- Los usuarios pueden ver solo su propio perfil
CREATE POLICY "Users can view own profile" ON user_profiles
    FOR SELECT
    TO public
    USING (auth.uid() = id);

-- Los usuarios pueden actualizar solo su propio perfil
CREATE POLICY "Users can update own profile" ON user_profiles
    FOR UPDATE
    TO public
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id AND role = 'user'); -- No pueden cambiar su rol

-- =====================================================
-- POLÍTICAS PARA LA TABLA AUTH.USERS (SOLO ADMINS)
-- =====================================================

-- Crear una vista para que los admins puedan ver todos los usuarios
-- Nota: Las vistas no necesitan políticas RLS, heredan los permisos de las tablas subyacentes
CREATE OR REPLACE VIEW admin_users_view AS
SELECT 
    au.id,
    au.email,
    au.email_confirmed_at,
    au.created_at,
    au.updated_at,
    au.last_sign_in_at,
    up.full_name,
    up.role
FROM auth.users au
LEFT JOIN user_profiles up ON au.id = up.id;

-- =====================================================
-- FUNCIONES AUXILIARES PARA ADMINISTRADORES
-- =====================================================

-- Función para verificar si el usuario actual es admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM user_profiles
        WHERE id = auth.uid()
        AND role = 'admin'
    ) OR EXISTS (
        SELECT 1 FROM auth.users
        WHERE id = auth.uid()
        AND email = 'saludablebela@gmail.com'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para obtener estadísticas de usuarios (solo para admins)
CREATE OR REPLACE FUNCTION get_user_stats()
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    -- Verificar si el usuario es admin
    IF NOT is_admin() THEN
        RAISE EXCEPTION 'Access denied. Admin privileges required.';
    END IF;
    
    SELECT json_build_object(
        'total_users', COUNT(*),
        'admin_users', COUNT(CASE WHEN role = 'admin' THEN 1 END),
        'regular_users', COUNT(CASE WHEN role = 'user' THEN 1 END),
        'users_last_30_days', COUNT(CASE WHEN created_at >= NOW() - INTERVAL '30 days' THEN 1 END),
        'confirmed_users', (
            SELECT COUNT(*) FROM auth.users 
            WHERE email_confirmed_at IS NOT NULL
        ),
        'unconfirmed_users', (
            SELECT COUNT(*) FROM auth.users 
            WHERE email_confirmed_at IS NULL
        )
    ) INTO result
    FROM user_profiles;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para obtener todos los usuarios (solo para admins)
CREATE OR REPLACE FUNCTION get_all_users()
RETURNS TABLE(
    id UUID,
    email TEXT,
    full_name TEXT,
    role TEXT,
    email_confirmed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    last_sign_in_at TIMESTAMPTZ
) AS $$
BEGIN
    -- Verificar si el usuario es admin
    IF NOT is_admin() THEN
        RAISE EXCEPTION 'Access denied. Admin privileges required.';
    END IF;
    
    RETURN QUERY
    SELECT 
        au.id,
        au.email,
        up.full_name,
        up.role,
        au.email_confirmed_at,
        au.created_at,
        au.last_sign_in_at
    FROM auth.users au
    LEFT JOIN user_profiles up ON au.id = up.id
    ORDER BY au.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- PERMISOS PARA FUNCIONES
-- =====================================================

-- Dar permisos de ejecución a las funciones
GRANT EXECUTE ON FUNCTION is_admin() TO public;
GRANT EXECUTE ON FUNCTION get_user_stats() TO public;
GRANT EXECUTE ON FUNCTION get_all_users() TO public;

-- =====================================================
-- INSTRUCCIONES DE USO:
-- =====================================================

/*
1. Ejecuta este script en el Editor SQL de Supabase
2. Los administradores (saludablebela@gmail.com y usuarios con role='admin') 
   tendrán acceso completo a:
   - Ver todos los perfiles de usuarios
   - Editar cualquier perfil
   - Eliminar cualquier perfil
   - Crear nuevos perfiles
   - Acceder a estadísticas de usuarios
   - Ver información completa de auth.users

3. Los usuarios regulares solo pueden:
   - Ver su propio perfil
   - Editar su propio perfil (sin cambiar el rol)
   - Crear su propio perfil al registrarse

4. Para usar las funciones en tu aplicación:
   - get_user_stats(): Obtiene estadísticas de usuarios
   - get_all_users(): Obtiene lista completa de usuarios
   - is_admin(): Verifica si el usuario actual es admin

5. En tu código JavaScript, puedes usar:
   const { data, error } = await supabaseClient.rpc('get_all_users');
   const { data: stats } = await supabaseClient.rpc('get_user_stats');
*/