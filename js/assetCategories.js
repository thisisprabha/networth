/**
 * Asset Categories Configuration
 * Defines all asset types, their display properties, and input configurations
 */
const assetCategories = {
  stocks: {
    name: "Stock Investments",
    icon: "trending-up",
    color: "text-green-500",
    fields: [
      {
        id: "stockValue",
        label: "Approximate Total Value",
        type: "slider",
        min: 0,
        max: 10000000,
        step: 1000,
        defaultValue: 0,
        format: "currency",
      },
    ],
    growthRate: {
      min: 15,
      max: 20,
      default: 17.5,
    },
  },
  mutualFunds: {
    name: "Mutual Fund Investments",
    icon: "bar-chart-2",
    color: "text-blue-500",
    fields: [
      {
        id: "fundValue",
        label: "Approximate Total Value",
        type: "slider",
        min: 0,
        max: 10000000,
        step: 1000,
        defaultValue: 0,
        format: "currency",
      },
    ],
    growthRate: {
      min: 10,
      max: 13,
      default: 11.5,
    },
  },
  gold: {
    name: "Gold",
    icon: "circle",
    color: "text-yellow-500",
    fields: [
      {
        id: "goldQuantity",
        label: "Quantity (grams)",
        type: "number",
        min: 0,
        step: 0.1,
        defaultValue: 0,
      },
      {
        id: "goldRate",
        label: "Current Rate (₹ per gram)",
        type: "number",
        min: 0,
        step: 100,
        defaultValue: 5000,
      },
    ],
    growthRate: {
      min: 9,
      max: 10,
      default: 9.5,
    },
  },
  fixedDeposits: {
    name: "Fixed Deposits",
    icon: "inbox",
    color: "text-gray-500",
    fields: [
      {
        id: "principalAmount",
        label: "Principal Amount",
        type: "slider",
        min: 0,
        max: 5000000,
        step: 1000,
        defaultValue: 0,
        format: "currency",
      },
      {
        id: "interestRate",
        label: "Interest Rate (%)",
        type: "number",
        min: 0,
        max: 12,
        step: 0.1,
        defaultValue: 7,
      },
      {
        id: "maturityDate",
        label: "Maturity Date (optional)",
        type: "date",
        defaultValue: "",
      },
    ],
    growthRate: {
      default: 7,
    },
  },
  personalAssets: {
    name: "Personal Property",
    icon: "package",
    color: "text-purple-500",
    fields: [
      {
        id: "assetType",
        label: "Asset Type",
        type: "select",
        options: [
          { value: "bike", label: "Bike", defaultValue: 100000 },
          { value: "car", label: "Car", defaultValue: 800000 },
          { value: "cycle", label: "Cycle", defaultValue: 10000 },
          { value: "phone", label: "iPhone/Smartphone", defaultValue: 80000 },
          { value: "laptop", label: "Laptop", defaultValue: 90000 },
          { value: "pc", label: "PC", defaultValue: 100000 },
          { value: "watch", label: "Smart Watch", defaultValue: 30000 },
          { value: "console", label: "Gaming Console", defaultValue: 50000 },
          { value: "shoes", label: "Luxury Shoes", defaultValue: 15000 },
          {
            value: "watch_luxury",
            label: "Luxury Watch",
            defaultValue: 100000,
          },
          { value: "other", label: "Other", defaultValue: 10000 },
        ],
      },
      {
        id: "assetName",
        label: "Description (optional)",
        type: "text",
        defaultValue: "",
      },
      {
        id: "quantity",
        label: "Quantity",
        type: "number",
        min: 1,
        step: 1,
        defaultValue: 1,
      },
      {
        id: "assetValue",
        label: "Current Value",
        type: "slider",
        min: 0,
        max: 2000000,
        step: 1000,
        defaultValue: 0,
        format: "currency",
      },
    ],
    growthRate: {
      min: -10,
      max: -5,
      default: -7.5,
    },
  },
  bonds: {
    name: "Bonds",
    icon: "file-text",
    color: "text-blue-600",
    fields: [
      {
        id: "bondValue",
        label: "Approximate Total Value",
        type: "slider",
        min: 0,
        max: 5000000,
        step: 1000,
        defaultValue: 0,
        format: "currency",
      },
    ],
    growthRate: {
      default: 8,
    },
  },
  land: {
    name: "Land",
    icon: "map",
    color: "text-green-700",
    fields: [
      {
        id: "landValue",
        label: "Estimated Current Value",
        type: "slider",
        min: 100000,
        max: 50000000,
        step: 100000,
        defaultValue: 1000000,
        format: "currency",
      },
    ],
    growthRate: {
      default: 9,
    },
  },
  home: {
    name: "Home (Real Estate)",
    icon: "home",
    color: "text-red-500",
    fields: [
      {
        id: "homeValue",
        label: "Estimated Current Value",
        type: "slider",
        min: 500000,
        max: 50000000,
        step: 100000,
        defaultValue: 5000000,
        format: "currency",
      },
    ],
    growthRate: {
      default: 9,
    },
  },
  savings: {
    name: "Savings",
    icon: "dollar-sign",
    color: "text-green-600",
    fields: [
      {
        id: "savingsBalance",
        label: "Current Balance",
        type: "slider",
        min: 0,
        max: 5000000,
        step: 1000,
        defaultValue: 0,
        format: "currency",
      },
    ],
    growthRate: {
      default: 4,
    },
  },
  emergencySavings: {
    name: "Emergency Savings",
    icon: "shield",
    color: "text-yellow-600",
    fields: [
      {
        id: "emergencyBalance",
        label: "Current Balance",
        type: "slider",
        min: 0,
        max: 1000000,
        step: 1000,
        defaultValue: 0,
        format: "currency",
      },
    ],
    growthRate: {
      default: 4,
    },
  },

  // Add these new categories within the const assetCategories = { ... }; object

  esop: {
    name: "ESOP",
    icon: "briefcase", // Feather icon name
    color: "text-indigo-500", // Tailwind CSS color class
    fields: [
      {
        id: "esopCurrentValue",
        label: "Approximate Current Value per Share", // Changed label slightly
        type: "number",
        min: 0,
        step: 1, // Adjust step as needed
        defaultValue: 1,
      },
      {
        id: "esopShares",
        label: "Number of Vested Shares", // Changed label slightly
        type: "number",
        min: 0,
        step: 1, // Adjust step as needed
        defaultValue: 0,
      },
    ],
    growthRate: { default: 15 }, // Assign a sensible default growth rate for projection, adjust as needed
  },
  privateEquity: {
    name: "Private Equity",
    icon: "trending-up", // Changed icon
    color: "text-teal-500",
    fields: [
      {
        id: "peValue",
        label: "Estimated Current Value",
        type: "slider", // Changed to slider for larger values
        min: 0,
        max: 50000000, // Adjust max as needed
        step: 10000, // Adjust step as needed
        defaultValue: 100000, // Sensible default
        format: "currency",
      },
      {
        id: "peUnits", // Changed from 'shares' to 'units' for clarity
        label: "Number of Units/Shares (Optional)",
        type: "number",
        min: 0,
        step: 1,
        defaultValue: 1,
      },
    ],
    growthRate: { default: 20 }, // Assign a sensible default growth rate, adjust as needed
  },
  vpf_ppf: {
    name: "VPF/PPF",
    icon: "lock", // Changed icon
    color: "text-orange-500",
    fields: [
      {
        id: "vpfAmount",
        label: "Current Balance", // Changed label
        type: "slider",
        min: 0,
        max: 10000000, // Adjust max as needed
        step: 1000,
        defaultValue: 0,
        format: "currency",
      },
      // Interest rate is implicitly handled by growthRate
    ],
    growthRate: { default: 8.5 }, // As specified
  },
  silver: {
    name: "Silver",
    icon: "disc",
    color: "text-gray-400",
    fields: [
      {
        id: "silverGrams",
        label: "Quantity (grams)", // Kept label
        type: "number",
        min: 0,
        step: 1, // Changed step to 1 for grams
        defaultValue: 0,
      },
      {
        id: "silverRate",
        label: "Current Rate (₹ per gram)",
        type: "number",
        min: 0,
        step: 1, // Changed step to 1 for rate
        defaultValue: 85, // Example current rate
      },
      // Quantity seems covered by grams * rate
    ],
    growthRate: { default: 9.5 }, // As specified (average of 9-10%)
  },

  // End of new categories additions
};

// Export for module use
if (typeof module !== "undefined" && module.exports) {
  module.exports = assetCategories;
}
