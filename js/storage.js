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
    this.SYNC_TIMESTAMP_KEY = "networthvault_sync_timestamp";

    // Initialize storage event listener for cross-context sync
    this.initStorageSync();
  }

  /**
   * Initialize storage event listener for cross-context synchronization
   */
  initStorageSync() {
    window.addEventListener("storage", (event) => {
      console.log("Storage event detected:", event.key, event.newValue);
      if (event.key === this.ASSETS_KEY || event.key === this.SETTINGS_KEY) {
        try {
          const newData = event.newValue ? JSON.parse(event.newValue) : null;
          if (newData) {
            console.log(`Syncing ${event.key} with new data:`, newData);
            localStorage.setItem(event.key, JSON.stringify(newData));
            // Update sync timestamp
            localStorage.setItem(
              this.SYNC_TIMESTAMP_KEY,
              Date.now().toString()
            );
          }
        } catch (error) {
          console.error("Error syncing storage data:", error);
        }
      }
    });
  }

  /**
   * Merge assets from another context (e.g., browser to Home Screen)
   * @param {Array} newAssets Assets from another context
   */
  mergeAssets(newAssets) {
    const currentAssets = this.getAssets();
    const mergedAssets = [...currentAssets];

    newAssets.forEach((newAsset) => {
      const existingIndex = mergedAssets.findIndex((a) => a.id === newAsset.id);
      if (existingIndex >= 0) {
        // Update existing asset if newer
        if (
          new Date(newAsset.updatedAt) >
          new Date(mergedAssets[existingIndex].updatedAt)
        ) {
          mergedAssets[existingIndex] = newAsset;
        }
      } else {
        // Add new asset
        mergedAssets.push(newAsset);
      }
    });

    this.saveAssets(mergedAssets);
    return mergedAssets;
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
      console.log("Exporting assets:", assets);
      const headers = [
        "id",
        "category",
        "name",
        "icon",
        "color",
        "values",
        "createdAt",
        "updatedAt",
      ];
      const csvRows = [
        headers.join(","), // Header row
        ...assets.map((asset) =>
          [
            asset.id || "",
            asset.category || "",
            `"${(asset.name || "").replace(/"/g, '""')}"`, // Escape quotes
            asset.icon || "",
            asset.color || "",
            `"${JSON.stringify(asset.values || {}).replace(/"/g, '""')}"`, // Stringify values
            asset.createdAt || "",
            asset.updatedAt || "",
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
   * @returns {Promise} Resolves with number of imported assets, rejects on error
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
            const rows = [];
            const lines = text.split("\n").filter((line) => line.trim());
            for (const line of lines) {
              const fields = [];
              const regex = /("([^"]*"")*"|[^,]*)(,|$)/g;
              let match;
              let currentLine = line + ",";
              while ((match = regex.exec(currentLine)) !== null) {
                let field = match[1];
                if (field.startsWith('"') && field.endsWith('"')) {
                  field = field.slice(1, -1).replace(/""/g, '"');
                }
                fields.push(field.trim());
                if (match[3] === "") break;
              }
              if (fields.length >= 8) rows.push(fields);
            }

            console.log("Parsed CSV rows:", rows);

            const headers = rows[0];
            const expectedHeaders = [
              "id",
              "category",
              "name",
              "icon",
              "color",
              "values",
              "createdAt",
              "updatedAt",
            ];
            if (!expectedHeaders.every((h, i) => h === headers[i])) {
              throw new Error(
                "Invalid CSV format. Expected headers: " +
                  expectedHeaders.join(",")
              );
            }

            const validCategories = Object.keys(assetCategories);
            console.log("Valid categories:", validCategories);

            const assets = this.getAssets();
            const existingIds = new Set(assets.map((a) => a.id));

            const newAssets = rows
              .slice(1)
              .map((row, index) => {
                try {
                  console.log(`Processing row ${index + 2}:`, row);
                  if (row.length < headers.length) {
                    console.warn(
                      `Row ${index + 2} has insufficient columns (${
                        row.length
                      }):`,
                      row
                    );
                    return null;
                  }
                  const valuesStr = row[5];
                  let values;
                  try {
                    values = valuesStr ? JSON.parse(valuesStr) : {};
                  } catch (parseError) {
                    console.warn(
                      `Invalid values JSON in row ${index + 2}:`,
                      valuesStr,
                      parseError
                    );
                    return null;
                  }

                  const asset = {
                    id: row[0] || this.generateId(),
                    category: row[1] || "",
                    name: row[2],
                    icon: row[3] || "",
                    color: row[4] || "",
                    values,
                    createdAt: row[6] || new Date().toISOString(),
                    updatedAt: row[7] || new Date().toISOString(),
                  };

                  if (!asset.name || asset.name.trim() === "") {
                    console.warn(`Skipping row ${index + 2}: Missing name`);
                    return null;
                  }
                  if (!validCategories.includes(asset.category)) {
                    console.warn(
                      `Skipping row ${index + 2}: Invalid category '${
                        asset.category
                      }'`
                    );
                    return null;
                  }

                  return asset;
                } catch (rowError) {
                  console.warn(
                    `Skipping row ${index + 2}: ${rowError.message}`,
                    rowError
                  );
                  return null;
                }
              })
              .filter((asset) => asset !== null);

            console.log(`Assets to add: ${newAssets.length}`, newAssets);
            if (newAssets.length > 0) {
              this.saveAssets([...assets, ...newAssets]);
            }
            resolve(newAssets.length);
          } catch (error) {
            console.error("Import error:", error);
            reject(error);
          }
        };
        reader.onerror = () => reject(new Error("Failed to read file"));
        reader.readAsText(file);
      } catch (error) {
        console.error("Import initialization error:", error);
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
    localStorage.removeItem(this.SYNC_TIMESTAMP_KEY);
  }
}

// Create a singleton instance
const storageService = new StorageService();
