const CACHE_NAME = "networth-cache-v1";
const urlsToCache = [
  "/",
  "/index.html",
  "/styles.css",
  "/manifest.json",
  "/assets/icon-192x192.png",
  "/assets/icon-512x512.png",
  "/js/app.js",
  "/js/storage.js",
  "/js/calculations.js",
  "/js/assetCategories.js",
  "/js/feather.min.js",
  "/js/tailwind.js",
  "/js/components/assetForm.js",
  "/js/components/slider.js",
  "/js/components/dashboard.js",
  "/js/components/projection.js",
];
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log("Caching app files:", urlsToCache);
      return cache.addAll(urlsToCache).catch((error) => {
        console.error("Cache addAll failed:", error);
      });
    })
  );
});

self.addEventListener("fetch", (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => {
      if (response) {
        return response;
      }
      return fetch(event.request).catch(() => {
        if (event.request.mode === "navigate") {
          return caches.match("/index.html");
        }
      });
    })
  );
});

self.addEventListener("activate", (event) => {
  const cacheWhitelist = [CACHE_NAME];
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (!cacheWhitelist.includes(cacheName)) {
            console.log("Deleting old cache:", cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});
