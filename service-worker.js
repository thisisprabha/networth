// Simple Service Worker for offline functionality
const CACHE_NAME = 'networth-cache-v1';
const urlsToCache = [
  '/',
  '/index.html',
  '/styles.css',
  '/js/app.js',
  '/js/storage.js',
  '/js/calculations.js',
  '/js/assetCategories.js',
  '/js/ui.js',
  '/js/components/slider.js',
  '/js/components/assetForm.js',
  '/js/components/dashboard.js',
];

// Install event - cache assets
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        return cache.addAll(urlsToCache);
      })
  );
});

// Fetch event - serve from cache if available
self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(response => {
        // Cache hit - return the response
        if (response) {
          return response;
        }
        return fetch(event.request);
      })
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});