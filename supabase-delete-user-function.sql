-- FUNCIÓN RPC PARA ELIMINAR USUARIOS DE FORMA SEGURA
-- Este archivo agrega la funcionalidad para que los administradores puedan eliminar usuarios

-- 1. FUNCIÓN RPC PARA ELIMINAR USUARIO (SOLO ADMINISTRADORES)
CREATE OR REPLACE FUNCTION public.delete_user_admin(target_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    current_user_email TEXT;
    target_user_exists BOOLEAN;
BEGIN
    -- Obtener el email del usuario actual desde el JWT
    current_user_email := auth.jwt() ->> 'email';
    
    -- Verificar si el usuario actual es admin
    IF current_user_email != 'saludablebela@gmail.com' THEN
        RAISE EXCEPTION 'Access denied. Admin privileges required.';
    END IF;
    
    -- Verificar que el usuario objetivo existe
    SELECT EXISTS(
        SELECT 1 FROM public.user_profiles 
        WHERE id = target_user_id
    ) INTO target_user_exists;
    
    IF NOT target_user_exists THEN
        RAISE EXCEPTION 'User not found.';
    END IF;
    
    -- Prevenir que el admin se elimine a sí mismo
    IF target_user_id = auth.uid() THEN
        RAISE EXCEPTION 'Cannot delete your own account.';
    END IF;
    
    -- Eliminar el perfil del usuario de user_profiles
    DELETE FROM public.user_profiles 
    WHERE id = target_user_id;
    
    -- Nota: No podemos eliminar directamente de auth.users con RPC
    -- El usuario seguirá existiendo en auth.users pero sin perfil
    -- Para eliminación completa, se requiere acceso directo a Supabase Dashboard
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error deleting user: %', SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. OTORGAR PERMISOS DE EJECUCIÓN
GRANT EXECUTE ON FUNCTION public.delete_user_admin(UUID) TO authenticated;

-- INSTRUCCIONES:
-- 1. Ejecutar este archivo en el SQL Editor de Supabase
-- 2. La función delete_user_admin() estará disponible para usar desde el cliente
-- 3. Solo eliminará el perfil del usuario, no la cuenta de autenticación completa
-- 4. Para eliminación completa de auth.users, se requiere acceso al Dashboard de Supabase