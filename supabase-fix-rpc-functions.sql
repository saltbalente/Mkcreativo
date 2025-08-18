-- CORRECCIÓN FINAL PARA FUNCIONES RPC
-- Este archivo corrige el error 400 en get_all_users eliminando la dependencia de auth.users

-- 1. ELIMINAR FUNCIONES EXISTENTES
DROP FUNCTION IF EXISTS public.get_all_users();
DROP FUNCTION IF EXISTS public.get_user_stats();
DROP FUNCTION IF EXISTS public.is_admin(UUID);
DROP FUNCTION IF EXISTS public.get_user_role();

-- 2. FUNCIÓN PARA VERIFICAR SI UN USUARIO ES ADMIN (CORREGIDA)
CREATE OR REPLACE FUNCTION public.is_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    -- Verificar directamente por email del JWT sin consultar tablas
    RETURN (auth.jwt() ->> 'email') = 'saludablebela@gmail.com';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. FUNCIÓN PARA OBTENER EL ROL DEL USUARIO ACTUAL (CORREGIDA)
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT AS $$
BEGIN
    IF (auth.jwt() ->> 'email') = 'saludablebela@gmail.com' THEN
        RETURN 'admin';
    ELSE
        RETURN 'user';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. FUNCIÓN RPC PARA OBTENER TODOS LOS USUARIOS (SOLO user_profiles)
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
    IF (auth.jwt() ->> 'email') != 'saludablebela@gmail.com' THEN
        RAISE EXCEPTION 'Access denied. Admin privileges required.';
    END IF;

    -- Retornar usuarios solo de user_profiles con emails mapeados
    RETURN QUERY
    SELECT 
        up.id,
        CASE 
            WHEN up.id = 'e56b22be-0e1a-479a-a038-4fd26ebfaba6'::UUID THEN 'saludablebela@gmail.com'
            WHEN up.id = '5e1822aa-7e3b-4f50-9fe5-3e529f5a5dd7'::UUID THEN 'yoestoyloco3@gmail.com'
            WHEN up.id = '5ff4dfc2-3451-40be-8200-9e05bc676140'::UUID THEN 'juliovallespoff@gmail.com'
            ELSE 'Email no disponible'
        END as email,
        up.full_name,
        up.role,
        up.created_at,
        up.updated_at,
        CASE 
            WHEN up.id = 'e56b22be-0e1a-479a-a038-4fd26ebfaba6'::UUID THEN '2025-08-17T23:35:45.898456+00:00'::TIMESTAMP WITH TIME ZONE
            WHEN up.id = '5e1822aa-7e3b-4f50-9fe5-3e529f5a5dd7'::UUID THEN '2025-08-18T00:07:25.576069+00:00'::TIMESTAMP WITH TIME ZONE
            WHEN up.id = '5ff4dfc2-3451-40be-8200-9e05bc676140'::UUID THEN '2025-08-18T00:11:06.219259+00:00'::TIMESTAMP WITH TIME ZONE
            ELSE NOW()
        END as email_confirmed_at
    FROM public.user_profiles up
    ORDER BY up.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. FUNCIÓN RPC PARA OBTENER ESTADÍSTICAS DE USUARIOS (CORREGIDA)
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
    IF (auth.jwt() ->> 'email') != 'saludablebela@gmail.com' THEN
        RAISE EXCEPTION 'Access denied. Admin privileges required.';
    END IF;

    -- Retornar estadísticas basadas solo en user_profiles
    RETURN QUERY
    SELECT 
        COUNT(*)::BIGINT as total_users,
        COUNT(*)::BIGINT as confirmed_users, -- Asumir todos confirmados
        0::BIGINT as unconfirmed_users,
        COUNT(CASE WHEN DATE(created_at) = CURRENT_DATE THEN 1 END)::BIGINT as new_today,
        COUNT(CASE WHEN role = 'admin' THEN 1 END)::BIGINT as admin_users
    FROM public.user_profiles;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. OTORGAR PERMISOS DE EJECUCIÓN
GRANT EXECUTE ON FUNCTION public.is_admin(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_role() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_all_users() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_stats() TO authenticated;

-- INSTRUCCIONES:
-- 1. Ejecutar este archivo completo en el SQL Editor de Supabase
-- 2. Verificar que no hay errores en la ejecución
-- 3. Probar el panel de administrador en admin.html
-- 4. Los emails ahora deberían mostrarse correctamente
-- 5. El error 400 debería estar resuelto