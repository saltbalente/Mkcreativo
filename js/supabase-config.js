// Configuración de Supabase
const SUPABASE_URL = 'https://udjzuyurelatvgpgwuye.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVkanp1eXVyZWxhdHZncGd3dXllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU0NzA5MTcsImV4cCI6MjA3MTA0NjkxN30.SN1MlphEN9bMCOhMT2ZRjfncU9QR4GWINPSH1y_j5xc';

// Inicializar cliente de Supabase
const supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    auth: {
        redirectTo: window.location.origin + '/bienvenido.html'
    }
});

// Funciones de autenticación
const auth = {
    // Registrar nuevo usuario
    async signUp(email, password, userData = {}) {
        try {
            const { data, error } = await supabaseClient.auth.signUp({
                email: email,
                password: password,
                options: {
                    data: userData
                }
            });
            
            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            console.error('Error en registro:', error.message);
            return { success: false, error: error.message };
        }
    },

    // Iniciar sesión
    async signIn(email, password) {
        try {
            const { data, error } = await supabaseClient.auth.signInWithPassword({
                email: email,
                password: password
            });
            
            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            console.error('Error en login:', error.message);
            return { success: false, error: error.message };
        }
    },

    // Cerrar sesión
    async signOut() {
        try {
            const { error } = await supabaseClient.auth.signOut();
            if (error) throw error;
            return { success: true };
        } catch (error) {
            console.error('Error al cerrar sesión:', error.message);
            return { success: false, error: error.message };
        }
    },

    // Obtener usuario actual
    async getCurrentUser() {
        try {
            const { data: { user } } = await supabaseClient.auth.getUser();
            return user;
        } catch (error) {
            console.error('Error al obtener usuario:', error.message);
            return null;
        }
    },

    // Verificar si el usuario es administrador
    async isAdmin(user) {
        if (!user) return false;
        
        // Verificar por email específico
        if (user.email === 'saludablebela@gmail.com') {
            return true;
        }
        
        try {
            // Verificar en la tabla user_profiles
            const { data, error } = await supabaseClient
                .from('user_profiles')
                .select('role')
                .eq('id', user.id)
                .single();
            
            if (error) {
                console.error('Error checking admin status:', error);
                return false;
            }
            
            return data?.role === 'admin';
        } catch (error) {
            console.error('Error in isAdmin:', error);
            return false;
        }
    },

    // Escuchar cambios de autenticación
    onAuthStateChange(callback) {
        return supabaseClient.auth.onAuthStateChange(callback);
    }
};

// Funciones de utilidad
const utils = {
    // Mostrar mensaje de error
    showError(message, elementId = 'error-message') {
        const errorElement = document.getElementById(elementId);
        if (errorElement) {
            errorElement.textContent = message;
            errorElement.style.display = 'block';
            setTimeout(() => {
                errorElement.style.display = 'none';
            }, 5000);
        }
    },

    // Mostrar mensaje de éxito
    showSuccess(message, elementId = 'success-message') {
        const successElement = document.getElementById(elementId);
        if (successElement) {
            successElement.textContent = message;
            successElement.style.display = 'block';
            setTimeout(() => {
                successElement.style.display = 'none';
            }, 5000);
        }
    },

    // Redirigir a página
    redirect(url) {
        window.location.href = url;
    },

    // Validar email
    isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    },

    // Validar contraseña
    isValidPassword(password) {
        return password.length >= 6;
    }
};

// Exportar para uso global
window.auth = auth;
window.utils = utils;
window.supabaseClient = supabaseClient;