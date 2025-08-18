-- =====================================================
-- CÓDIGO SQL PARA ACTUALIZAR SUPABASE - mkCreativo
-- (Solo funciones RPC y políticas nuevas)
-- =====================================================

-- NOTA: Este archivo contiene solo las actualizaciones necesarias
-- para agregar las funciones RPC faltantes sin recrear tablas existentes

-- 1. FUNCIÓN RPC PARA OBTENER TODOS LOS USUARIOS (SOLO ADMINS)
CREATE OR REPLACE FUNCTION public.get_all_users()
RETURNS TABLE(
    id UUID,
    email TEXT,
    full_name TEXT,
    role TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    email_confirmed_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    -- Verificar si el usuario actual es admin
    IF NOT (
        EXISTS (
            SELECT 1 FROM public.user_profiles 
            WHERE user_profiles.id = auth.uid() 
            AND user_profiles.role = 'admin'
        ) OR 
        auth.jwt() ->> 'email' = 'saludablebela@gmail.com'
    ) THEN
        RAISE EXCEPTION 'Access denied. Admin privileges required.';
    END IF;

    -- Retornar todos los usuarios con información combinada
    RETURN QUERY
    SELECT 
        up.id,
        au.email,
        up.full_name,
        up.role,
        up.created_at,
        up.updated_at,
        au.email_confirmed_at
    FROM public.user_profiles up
    LEFT JOIN auth.users au ON up.id = au.id
    ORDER BY up.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. FUNCIÓN RPC PARA OBTENER ESTADÍSTICAS DE USUARIOS (SOLO ADMINS)
CREATE OR REPLACE FUNCTION public.get_user_stats()
RETURNS TABLE(
    total_users BIGINT,
    confirmed_users BIGINT,
    unconfirmed_users BIGINT,
    new_today BIGINT,
    admin_users BIGINT
) AS $$
BEGIN
    -- Verificar si el usuario actual es admin
    IF NOT (
        EXISTS (
            SELECT 1 FROM public.user_profiles 
            WHERE user_profiles.id = auth.uid() 
            AND user_profiles.role = 'admin'
        ) OR 
        auth.jwt() ->> 'email' = 'saludablebela@gmail.com'
    ) THEN
        RAISE EXCEPTION 'Access denied. Admin privileges required.';
    END IF;

    -- Retornar estadísticas
    RETURN QUERY
    SELECT 
        COUNT(*)::BIGINT as total_users,
        COUNT(CASE WHEN au.email_confirmed_at IS NOT NULL THEN 1 END)::BIGINT as confirmed_users,
        COUNT(CASE WHEN au.email_confirmed_at IS NULL THEN 1 END)::BIGINT as unconfirmed_users,
        COUNT(CASE WHEN DATE(up.created_at) = CURRENT_DATE THEN 1 END)::BIGINT as new_today,
        COUNT(CASE WHEN up.role = 'admin' THEN 1 END)::BIGINT as admin_users
    FROM public.user_profiles up
    LEFT JOIN auth.users au ON up.id = au.id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. VERIFICAR Y CREAR FUNCIÓN is_admin SI NO EXISTE
CREATE OR REPLACE FUNCTION public.is_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_profiles
        WHERE id = user_id AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. VERIFICAR Y CREAR FUNCIÓN get_user_role SI NO EXISTE
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT AS $$
BEGIN
    RETURN (
        SELECT role FROM public.user_profiles
        WHERE id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- INSTRUCCIONES DE USO:
-- =====================================================
-- 1. Copia y pega este código en el Editor SQL de Supabase
-- 2. Ejecuta todo el código
-- 3. Las funciones RPC estarán disponibles para el panel de administrador
-- 4. No se recrearán las tablas existentes
-- =====================================================