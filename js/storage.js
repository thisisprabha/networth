/**
 * Storage Service
 * Handles local storage operations for asset data persistence
 */
class StorageService {
  constructor() {
    // Storage keys
    this.ASSETS_KEY = "networthvault_assets";
    this.SETTINGS_KEY = "networthvault_settings";
    this.LAST_UPDATED_KEY = "networthvault_lastUpdated";
  }

  /**
   * Get all assets from local storage
   * @returns {Array} Array of asset objects
   */
  getAssets() {
    try {
      const assets = localStorage.getItem(this.ASSETS_KEY);
      return assets ? JSON.parse(assets) : [];
    } catch (error) {
      console.error("Error retrieving assets from storage:", error);
      return [];
    }
  }

  /**
   * Save assets to local storage
   * @param {Array} assets Array of asset objects
   */
  saveAssets(assets) {
    try {
      localStorage.setItem(this.ASSETS_KEY, JSON.stringify(assets));
      this.updateLastModified();
    } catch (error) {
      console.error("Error saving assets to storage:", error);
    }
  }

  /**
   * Add or update a single asset
   * @param {Object} asset Asset object to save
   */
  saveAsset(asset) {
    try {
      const assets = this.getAssets();
      const existingIndex = assets.findIndex((a) => a.id === asset.id);

      if (existingIndex >= 0) {
        assets[existingIndex] = asset;
      } else {
        // Ensure the asset has an ID
        if (!asset.id) {
          asset.id = this.generateId();
        }
        assets.push(asset);
      }

      this.saveAssets(assets);
      return asset;
    } catch (error) {
      console.error("Error saving asset:", error);
      return null;
    }
  }

  /**
   * Delete an asset by ID
   * @param {String} assetId ID of the asset to delete
   * @returns {Boolean} Success status
   */
  deleteAsset(assetId) {
    try {
      const assets = this.getAssets();
      const updatedAssets = assets.filter((a) => a.id !== assetId);

      if (updatedAssets.length !== assets.length) {
        this.saveAssets(updatedAssets);
        return true;
      }
      return false;
    } catch (error) {
      console.error("Error deleting asset:", error);
      return false;
    }
  }

  /**
   * Export assets to CSV
   */
  exportToCSV() {
    try {
      const assets = this.getAssets();
      const headers = [
        "id",
        "name",
        "value",
        "category",
        "color",
        "icon",
        "lastUpdated",
      ];
      const csvRows = [
        headers.join(","), // Header row
        ...assets.map((asset) =>
          [
            asset.id,
            `"${(asset.name || "").replace(/"/g, '""')}"`, // Escape quotes
            asset.value || 0,
            asset.category || "",
            asset.color || "",
            asset.icon || "",
            asset.lastUpdated || "",
          ].join(",")
        ),
      ];
      const csvContent = csvRows.join("\n");
      const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
      const url = URL.createObjectURL(blob);
      const link = document.createElement("a");
      link.setAttribute("href", url);
      link.setAttribute("download", "networth_backup.csv");
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);
    } catch (error) {
      console.error("Error exporting to CSV:", error);
      alert("Failed to export assets.");
    }
  }

  /**
   * Import assets from CSV
   * @param {File} file CSV file to import
   * @returns {Promise} Resolves on success, rejects on error
   */
  importFromCSV(file) {
    return new Promise((resolve, reject) => {
      try {
        if (!file || file.type !== "text/csv") {
          throw new Error("Please select a valid CSV file");
        }
        const reader = new FileReader();
        reader.onload = (e) => {
          try {
            const text = e.target.result;
            const rows = text.split("\n").map((row) => row.split(","));
            const headers = rows[0];
            const expectedHeaders = [
              "id",
              "name",
              "value",
              "category",
              "color",
              "icon",
              "lastUpdated",
            ];
            if (!expectedHeaders.every((h, i) => h === headers[i])) {
              throw new Error(
                "Invalid CSV format. Expected headers: " +
                  expectedHeaders.join(",")
              );
            }

            const validCategories = Object.keys(assetCategories); // From assetCategories.js
            const assets = this.getAssets();
            const existingIds = new Set(assets.map((a) => a.id));

            const newAssets = rows.slice(1).map((row) => {
              const asset = {
                id: row[0],
                name: row[1].replace(/^"|"$/g, "").replace(/""/g, '"'), // Unescape quotes
                value: parseFloat(row[2]),
                category: row[3],
                color: row[4] || "",
                icon: row[5] || "",
                lastUpdated: row[6] || new Date().toISOString(),
              };
              // Validate asset
              if (!asset.id) asset.id = this.generateId();
              if (!asset.name || asset.name.trim() === "") {
                throw new Error("Asset name is required");
              }
              if (isNaN(asset.value)) {
                throw new Error(`Invalid value for asset: ${asset.name}`);
              }
              if (!validCategories.includes(asset.category)) {
                throw new Error(
                  `Invalid category for asset ${asset.name}: ${asset.category}`
                );
              }
              return asset;
            });

            // Merge new assets (skip duplicates by id)
            const assetsToAdd = newAssets.filter((a) => !existingIds.has(a.id));
            if (assetsToAdd.length > 0) {
              this.saveAssets([...assets, ...assetsToAdd]);
            }
            resolve(assetsToAdd.length);
          } catch (error) {
            reject(error);
          }
        };
        reader.onerror = () => reject(new Error("Failed to read file"));
        reader.readAsText(file);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * Get app settings from local storage
   * @returns {Object} Settings object
   */
  getSettings() {
    try {
      const settings = localStorage.getItem(this.SETTINGS_KEY);
      return settings ? JSON.parse(settings) : this.getDefaultSettings();
    } catch (error) {
      console.error("Error retrieving settings:", error);
      return this.getDefaultSettings();
    }
  }

  /**
   * Save app settings to local storage
   * @param {Object} settings Settings object
   */
  saveSettings(settings) {
    try {
      localStorage.setItem(this.SETTINGS_KEY, JSON.stringify(settings));
    } catch (error) {
      console.error("Error saving settings:", error);
    }
  }

  /**
   * Get the date when assets were last updated
   * @returns {String} ISO date string or null
   */
  getLastUpdated() {
    return localStorage.getItem(this.LAST_UPDATED_KEY);
  }

  /**
   * Update the last modified timestamp
   */
  updateLastModified() {
    localStorage.setItem(this.LAST_UPDATED_KEY, new Date().toISOString());
  }

  /**
   * Generate a unique ID for assets
   * @returns {String} Unique ID
   */
  generateId() {
    return Date.now().toString(36) + Math.random().toString(36).substr(2, 5);
  }

  /**
   * Get default app settings
   * @returns {Object} Default settings
   */
  getDefaultSettings() {
    return {
      currency: "₹",
      darkMode: window.matchMedia("(prefers-color-scheme: dark)").matches,
      growthRates: this.getDefaultGrowthRates(),
    };
  }

  /**
   * Get default growth rates from asset categories
   * @returns {Object} Default growth rates for each asset type
   */
  getDefaultGrowthRates() {
    const rates = {};
    for (const [key, category] of Object.entries(assetCategories)) {
      if (category.growthRate && category.growthRate.default !== undefined) {
        rates[key] = category.growthRate.default;
      } else if (category.growthRate) {
        rates[key] =
          category.growthRate.min !== undefined
            ? (category.growthRate.min +
                (category.growthRate.max || category.growthRate.min)) /
              2
            : 0;
      }
    }
    return rates;
  }

  /**
   * Clear all stored data (for testing/reset)
   */
  clearAllData() {
    localStorage.removeItem(this.ASSETS_KEY);
    localStorage.removeItem(this.SETTINGS_KEY);
    localStorage.removeItem(this.LAST_UPDATED_KEY);
  }
}

// Create a singleton instance
const storageService = new StorageService();
