// Smooth scrolling for navigation links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// Scroll reveal animation
function revealOnScroll() {
    const reveals = document.querySelectorAll('.reveal');
    
    reveals.forEach(element => {
        const windowHeight = window.innerHeight;
        const elementTop = element.getBoundingClientRect().top;
        const elementVisible = 150;
        
        if (elementTop < windowHeight - elementVisible) {
            element.classList.add('active');
        }
    });
}

// Add reveal class to elements
document.addEventListener('DOMContentLoaded', function() {
    const elementsToReveal = document.querySelectorAll('.service-cards .card, .process-steps .step, .metric-card, .testimonial-card, .faq-item');
    elementsToReveal.forEach(element => {
        element.classList.add('reveal');
    });
    
    // Initial check
    revealOnScroll();
});

// Listen for scroll events
window.addEventListener('scroll', revealOnScroll);

// Parallax effect for hero section
window.addEventListener('scroll', () => {
    const scrolled = window.pageYOffset;
    const hero = document.querySelector('.hero-section');
    if (hero) {
        hero.style.transform = `translateY(${scrolled * 0.5}px)`;
    }
});

// Interactive card tilt effect
document.querySelectorAll('.service-cards .card').forEach(card => {
    card.addEventListener('mousemove', (e) => {
        const rect = card.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;
        
        const centerX = rect.width / 2;
        const centerY = rect.height / 2;
        
        const rotateX = (y - centerY) / 10;
        const rotateY = (centerX - x) / 10;
        
        card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) translateZ(20px)`;
    });
    
    card.addEventListener('mouseleave', () => {
        card.style.transform = 'perspective(1000px) rotateX(0) rotateY(0) translateZ(0)';
    });
});

// FAQ accordion functionality
document.querySelectorAll('.faq-item').forEach(item => {
    item.addEventListener('click', () => {
        const isActive = item.classList.contains('active');
        
        // Close all FAQ items
        document.querySelectorAll('.faq-item').forEach(faq => {
            faq.classList.remove('active');
        });
        
        // Open clicked item if it wasn't active
        if (!isActive) {
            item.classList.add('active');
        }
    });
});

// Form submission with enhanced feedback
document.querySelector('.contact-form').addEventListener('submit', function(e) {
    e.preventDefault();
    
    // Get form elements
    const submitBtn = this.querySelector('button[type="submit"]');
    const originalText = submitBtn.textContent;
    
    // Show loading state
    submitBtn.textContent = 'Enviando...';
    submitBtn.style.background = 'rgba(255, 255, 255, 0.05)';
    submitBtn.disabled = true;
    
    // Simulate form submission
    setTimeout(() => {
        // Show success message
        const successMessage = document.createElement('div');
        successMessage.innerHTML = `
            <div style="
                background: rgba(0, 255, 136, 0.1);
                border: 1px solid rgba(0, 255, 136, 0.3);
                color: #00ff88;
                padding: 20px;
                border-radius: 15px;
                text-align: center;
                margin-top: 20px;
                backdrop-filter: blur(10px);
            ">
                ✅ ¡Mensaje enviado exitosamente! Nos pondremos en contacto contigo pronto.
            </div>
        `;
        
        this.appendChild(successMessage);
        
        // Reset form
        this.reset();
        
        // Reset button
        submitBtn.textContent = originalText;
        submitBtn.style.background = '';
        submitBtn.disabled = false;
        
        // Remove success message after 5 seconds
        setTimeout(() => {
            successMessage.remove();
        }, 5000);
        
    }, 2000);
});

// Add floating animation to WhatsApp button
const whatsappBtn = document.querySelector('.whatsapp-btn');
if (whatsappBtn) {
    setInterval(() => {
        whatsappBtn.style.animation = 'none';
        setTimeout(() => {
            whatsappBtn.style.animation = 'bounce 0.6s ease';
        }, 10);
    }, 3000);
}

// Add bounce animation keyframes
const style = document.createElement('style');
style.textContent = `
    @keyframes bounce {
        0%, 20%, 60%, 100% {
            transform: translateY(0) scale(1);
        }
        40% {
            transform: translateY(-10px) scale(1.1);
        }
        80% {
            transform: translateY(-5px) scale(1.05);
        }
    }
`;
document.head.appendChild(style);

// Cursor trail effect (optional enhancement)
let mouseX = 0;
let mouseY = 0;
let trail = [];

document.addEventListener('mousemove', (e) => {
    mouseX = e.clientX;
    mouseY = e.clientY;
});

function createTrail() {
    trail.push({ x: mouseX, y: mouseY });
    
    if (trail.length > 10) {
        trail.shift();
    }
    
    // Update trail elements if they exist
    trail.forEach((point, index) => {
        const trailElement = document.getElementById(`trail-${index}`);
        if (trailElement) {
            trailElement.style.left = point.x + 'px';
            trailElement.style.top = point.y + 'px';
            trailElement.style.opacity = (index + 1) / trail.length;
        }
    });
    
    requestAnimationFrame(createTrail);
}

// Initialize cursor trail (commented out by default to avoid performance issues)
// createTrail();


