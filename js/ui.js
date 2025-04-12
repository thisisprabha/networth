/**
 * UI Service
 * Handles general UI operations and theme management
 */
class UIService {
    constructor() {
        // Check for system dark mode preference
        this.isDarkMode = window.matchMedia('(prefers-color-scheme: dark)').matches;
        
        // Initialize UI state
        this.init();
    }
    
    /**
     * Initialize UI
     */
    init() {
        // Apply dark mode if needed
        this.applyTheme();
        
        // Set up modal close button
        const closeModalBtn = document.getElementById('close-modal');
        const modal = document.getElementById('asset-modal');
        
        if (closeModalBtn && modal) {
            closeModalBtn.addEventListener('click', () => {
                modal.classList.add('hidden');
            });
            
            // Close modal when clicking outside content
            modal.addEventListener('click', (e) => {
                if (e.target === modal) {
                    modal.classList.add('hidden');
                }
            });
        }
        
        // Listen for system theme changes
        window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
            this.isDarkMode = e.matches;
            this.applyTheme();
        });
    }
    
    /**
     * Apply current theme to document
     */
    applyTheme() {
        if (this.isDarkMode) {
            document.documentElement.classList.add('dark');
        } else {
            document.documentElement.classList.remove('dark');
        }
    }
    
    /**
     * Toggle dark/light mode
     */
    toggleDarkMode() {
        this.isDarkMode = !this.isDarkMode;
        this.applyTheme();
    }
    
    /**
     * Show a notification message
     * @param {String} message Message to display
     * @param {String} type Message type (info, success, error)
     * @param {Number} duration Duration in milliseconds
     */
    showNotification(message, type = 'info', duration = 3000) {
        // Create notification element if it doesn't exist
        let notification = document.getElementById('notification');
        
        if (!notification) {
            notification = document.createElement('div');
            notification.id = 'notification';
            notification.className = 'fixed bottom-4 left-4 right-4 p-4 rounded-lg shadow-lg transition-all transform translate-y-full opacity-0';
            document.body.appendChild(notification);
        }
        
        // Set notification type styling
        switch (type) {
            case 'success':
                notification.className = notification.className.replace(/bg-\w+-\d+/g, '');
                notification.classList.add('bg-green-100', 'text-green-800', 'dark:bg-green-900', 'dark:text-green-100');
                break;
            case 'error':
                notification.className = notification.className.replace(/bg-\w+-\d+/g, '');
                notification.classList.add('bg-red-100', 'text-red-800', 'dark:bg-red-900', 'dark:text-red-100');
                break;
            default:
                notification.className = notification.className.replace(/bg-\w+-\d+/g, '');
                notification.classList.add('bg-blue-100', 'text-blue-800', 'dark:bg-blue-900', 'dark:text-blue-100');
                break;
        }
        
        // Set message content
        notification.textContent = message;
        
        // Show notification with animation
        setTimeout(() => {
            notification.classList.remove('translate-y-full', 'opacity-0');
        }, 10);
        
        // Hide after duration
        setTimeout(() => {
            notification.classList.add('translate-y-full', 'opacity-0');
        }, duration);
    }
    
    /**
     * Format a date for display
     * @param {String} dateString Date string to format
     * @returns {String} Formatted date
     */
    formatDate(dateString) {
        if (!dateString) return '';
        
        const date = new Date(dateString);
        return date.toLocaleDateString();
    }
    
    /**
     * Check for offline status and update UI
     */
    checkOfflineStatus() {
        const offlineStatus = document.querySelector('.offline-status');
        
        if (offlineStatus) {
            offlineStatus.textContent = navigator.onLine ? 'Online' : 'Offline';
            offlineStatus.className = navigator.onLine 
                ? 'offline-status text-green-700 dark:text-green-400' 
                : 'offline-status text-amber-700 dark:text-amber-400';
        }
    }
}

// Create a singleton instance
const uiService = new UIService();
