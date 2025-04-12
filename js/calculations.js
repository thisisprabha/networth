/**
 * Calculations Service
 * Handles net worth calculations and projections
 */
class CalculationsService {
  constructor(storageService) {
    this.storageService = storageService;
  }

  /**
   * Calculate current total net worth
   * @returns {Number} Total net worth
   */
  calculateNetWorth() {
    const assets = this.storageService.getAssets();
    let total = 0;

    assets.forEach((asset) => {
      total += this.getAssetValue(asset);
    });

    return total;
  }

  /**
   * Get the current value of a specific asset
   * @param {Object} asset Asset object
   * @returns {Number} Asset value
   */
  getAssetValue(asset) {
    const { category, values } = asset;

    switch (category) {
      case "stocks":
        return values.stockValue || 0;

      case "mutualFunds":
        return values.fundValue || 0;

      case "gold":
        return (values.goldQuantity || 0) * (values.goldRate || 0);

      case "fixedDeposits":
        return values.principalAmount || 0;

      case "personalAssets":
        return (values.assetValue || 0) * (values.quantity || 1);

      case "bonds":
        return values.bondValue || 0;

      case "land":
        return values.landValue || 0;

      case "home":
        return values.homeValue || 0;

      case "savings":
        return values.savingsBalance || 0;

      case "emergencySavings":
        return values.emergencyBalance || 0;

      // new var
      case "esop":
        // Value based on current value per share * number of shares
        return (values.esopCurrentValue || 0) * (values.esopShares || 0);
      case "privateEquity":
        // Assuming peValue is the total estimated value
        return values.peValue || 0;
      case "vpf_ppf":
        return values.vpfAmount || 0;
      case "silver":
        return (values.silverGrams || 0) * (values.silverRate || 0);

      // --- END OF NEW CATEGORIES ---

      default:
        return 0;
    }
  }

  /**
   * Project future net worth based on growth rates
   * @param {Number} months Number of months to project for
   * @returns {Object} Projected net worth data
   */
  projectNetWorth(months = 12) {
    const assets = this.storageService.getAssets();
    const settings = this.storageService.getSettings();
    const growthRates = settings.growthRates;

    // Monthly projection data points
    const projectionData = Array(months + 1)
      .fill(0)
      .map((_, i) => {
        return {
          month: i,
          value: 0,
        };
      });

    // Current total (month 0)
    projectionData[0].value = this.calculateNetWorth();

    // Calculate for each asset type
    assets.forEach((asset) => {
      const { category } = asset;
      const currentValue = this.getAssetValue(asset);

      // Get annual growth rate for this asset category
      const annualRate =
        growthRates[category] !== undefined
          ? growthRates[category]
          : assetCategories[category]?.growthRate?.default || 0;

      // Convert annual rate to monthly
      const monthlyRate = annualRate / 12 / 100;

      // Calculate monthly compound growth for this asset
      for (let i = 1; i <= months; i++) {
        const projectedValue = currentValue * Math.pow(1 + monthlyRate, i);
        projectionData[i].value += projectedValue;
      }
    });

    // Calculate totals by adding current values of assets not included in the projection
    for (let i = 1; i <= months; i++) {
      // Any assets not accounted for in the loop above would be added here
      // Currently all assets should be included in the projection
    }

    return projectionData;
  }

  /**
   * Get projected net worth after 1 year
   * @returns {Number} Projected net worth
   */
  getOneYearProjection() {
    const projectionData = this.projectNetWorth(12);
    return projectionData[12].value;
  }

  /**
   * Format currency number for display
   * @param {Number} amount Amount to format
   * @returns {String} Formatted amount string
   */
  //   formatCurrency(amount) {
  //     return new Intl.NumberFormat("en-IN", {
  //       maximumFractionDigits: 0,
  //     }).format(amount);
  //   }

  formatCurrency(amount) {
    if (amount === null || amount === undefined) return "0";

    const num = Number(amount);
    if (isNaN(num)) return "0";

    const formatter = new Intl.NumberFormat("en-IN", {
      style: "currency",
      currency: "INR",
      maximumFractionDigits: 0,
    });

    if (num >= 10000000) {
      return `${(num / 10000000).toFixed(1)}Cr`;
    } else if (num >= 100000) {
      return `${(num / 100000).toFixed(1)}L`;
    } else {
      return formatter.format(num);
    }
  }

  formatCurrency2(amount) {
    if (amount === null || amount === undefined) return "0";

    const num = Number(amount);
    if (isNaN(num)) return "0";

    const formatter2 = new Intl.NumberFormat("en-IN", {
      style: "currency",
      currency: "INR",
      maximumFractionDigits: 0,
    });

    if (num >= 10000000) {
      return `₹${(num / 10000000).toFixed(1)}Cr`;
    } else if (num >= 100000) {
      return `₹${(num / 100000).toFixed(1)}L`;
    } else {
      return formatter2.format(num);
    }
  }
  /**
   * Calculate growth percentage between two values
   * @param {Number} startValue Starting value
   * @param {Number} endValue Ending value
   * @returns {Number} Growth percentage
   */
  calculateGrowthPercentage(startValue, endValue) {
    if (startValue === 0) return 0;
    return ((endValue - startValue) / startValue) * 100;
  }

  /**
   * Get asset breakdown as percentages of total net worth
   * @returns {Array} Asset breakdown data
   */
  getAssetBreakdown() {
    const assets = this.storageService.getAssets();
    const totalNetWorth = this.calculateNetWorth();
    const breakdown = [];

    // Group assets by category
    const assetsByCategory = {};

    assets.forEach((asset) => {
      const { category } = asset;
      const value = this.getAssetValue(asset);

      if (!assetsByCategory[category]) {
        assetsByCategory[category] = 0;
      }

      assetsByCategory[category] += value;
    });

    // Calculate percentages
    for (const [category, value] of Object.entries(assetsByCategory)) {
      const percentage = totalNetWorth > 0 ? (value / totalNetWorth) * 100 : 0;

      breakdown.push({
        category,
        name: assetCategories[category]?.name || category,
        value,
        percentage,
      });
    }

    // Sort by value (descending)
    breakdown.sort((a, b) => b.value - a.value);

    return breakdown;
  }
}

// Create a singleton instance
const calculationsService = new CalculationsService(storageService);
