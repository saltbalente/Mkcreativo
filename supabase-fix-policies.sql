-- =====================================================
-- CÓDIGO SQL PARA CORREGIR POLÍTICAS RLS - mkCreativo
-- (Soluciona recursión infinita en políticas)
-- =====================================================

-- ELIMINAR TODAS LAS POLÍTICAS EXISTENTES
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.user_profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON public.user_profiles;
DROP POLICY IF EXISTS "Admins can delete all profiles" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.user_profiles;

-- ELIMINAR FUNCIONES EXISTENTES SI EXISTEN
DROP FUNCTION IF EXISTS public.get_all_users();
DROP FUNCTION IF EXISTS public.get_user_stats();
DROP FUNCTION IF EXISTS public.is_admin(UUID);
DROP FUNCTION IF EXISTS public.get_user_role();

-- CREAR POLÍTICAS CORREGIDAS (SIN RECURSIÓN)

-- Política para administradores específicos por email
CREATE POLICY "Admin email can view all profiles" ON public.user_profiles
    FOR SELECT USING (
        auth.jwt() ->> 'email' = 'saludablebela@gmail.com'
    );

CREATE POLICY "Admin email can update all profiles" ON public.user_profiles
    FOR UPDATE USING (
        auth.jwt() ->> 'email' = 'saludablebela@gmail.com'
    );

CREATE POLICY "Admin email can delete all profiles" ON public.user_profiles
    FOR DELETE USING (
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

-- CREAR FUNCIONES RPC CORREGIDAS

-- 1. FUNCIÓN PARA VERIFICAR SI UN USUARIO ES ADMIN (SIN RECURSIÓN)
CREATE OR REPLACE FUNCTION public.is_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    -- Verificar directamente por email sin consultar user_profiles
    RETURN (
        SELECT email FROM auth.users WHERE id = user_id
    ) = 'saludablebela@gmail.com';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. FUNCIÓN PARA OBTENER EL ROL DEL USUARIO ACTUAL
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT AS $$
BEGIN
    IF auth.jwt() ->> 'email' = 'saludablebela@gmail.com' THEN
        RETURN 'admin';
    ELSE
        RETURN 'user';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. FUNCIÓN RPC PARA OBTENER TODOS LOS USUARIOS (SOLO ADMINS)
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
    -- Verificar si el usuario actual es admin por email
    IF auth.jwt() ->> 'email' != 'saludablebela@gmail.com' THEN
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

-- 4. FUNCIÓN RPC PARA OBTENER ESTADÍSTICAS DE USUARIOS (SOLO ADMINS)
CREATE OR REPLACE FUNCTION public.get_user_stats()
RETURNS TABLE(
    total_users BIGINT,
    confirmed_users BIGINT,
    unconfirmed_users BIGINT,
    new_today BIGINT,
    admin_users BIGINT
) AS $$
BEGIN
    -- Verificar si el usuario actual es admin por email
    IF auth.jwt() ->> 'email' != 'saludablebela@gmail.com' THEN
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

-- =====================================================
-- INSTRUCCIONES DE USO:
-- =====================================================
-- 1. Copia y pega este código en el Editor SQL de Supabase
-- 2. Ejecuta todo el código
-- 3. Las políticas RLS no tendrán recursión infinita
-- 4. Las funciones RPC funcionarán correctamente
-- 5. Solo saludablebela@gmail.com tendrá acceso de administrador
-- =====================================================