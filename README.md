# NetWorth - Private Asset Tracking Application

A **privacy-first, offline-capable** Progressive Web App (PWA) for tracking your net worth and financial assets. Built with vanilla JavaScript and designed for complete privacy - all data stays on your device.

![NetWorth Dashboard](assets/logo.svg)

## 🌟 Features

### 💰 **Comprehensive Asset Tracking**
- **Investment Assets**: Stocks, Mutual Funds, Bonds, ESOP, Private Equity
- **Precious Metals**: Gold, Silver with real-time rate calculations
- **Real Estate**: Home, Land properties
- **Savings**: Bank accounts, Emergency funds, VPF/PPF
- **Personal Assets**: Cars, Bikes, Electronics, Luxury items with depreciation tracking

### 📊 **Smart Calculations**
- **Real-time Net Worth**: Instant calculation of total assets
- **Growth Projections**: 1-year forecast based on historical returns
- **Asset Breakdown**: Visual representation of asset distribution
- **Dynamic Growth Rates**: Category-specific growth assumptions

### 🔒 **Privacy & Security**
- **PIN Protection**: 4-digit PIN authentication
- **Offline-First**: All data stored locally, no cloud dependency
- **No Analytics**: Zero tracking, complete privacy
- **Encrypted Storage**: Local data encryption using CryptoJS

### 📱 **Modern PWA Experience**
- **Mobile-Optimized**: Responsive design for all devices
- **Installable**: Add to home screen functionality
- **Offline Support**: Works without internet connection
- **Fast Loading**: Service worker caching for instant access

## 🚀 Quick Start

### Option 1: Use Live Version
Visit: [NetWorth App](https://thisisprabha.github.io/networth) (if deployed)

### Option 2: Local Development
```bash
# Clone the repository
git clone https://github.com/thisisprabha/networth.git
cd networth

# Serve locally (Python)
python -m http.server 8000

# Or use Node.js
npx serve .

# Or use any local web server
# Then open http://localhost:8000
```

## 💡 How to Use

### First Time Setup
1. **Set PIN**: Create a 4-digit PIN for app security
2. **Add Assets**: Click the "+" button to add your first asset
3. **Choose Category**: Select from 13+ asset categories
4. **Enter Details**: Use sliders/inputs to set values
5. **Track Growth**: Watch your net worth and projections update

### Adding Assets
The app supports these asset categories:

| Category | Examples | Growth Rate |
|----------|----------|-------------|
| 🏢 **Stocks** | Individual stocks, equity investments | 17.5% |
| 📈 **Mutual Funds** | SIP, lump sum investments | 11.5% |
| 🥇 **Gold** | Jewelry, coins, bars | 9.5% |
| 🥈 **Silver** | Coins, bars, jewelry | 9.5% |
| 🏠 **Real Estate** | Home, land properties | 9% |
| 💼 **ESOP** | Employee stock options | 15% |
| 📊 **Bonds** | Government, corporate bonds | 8% |
| 🔒 **VPF/PPF** | Provident fund accounts | 8.5% |
| 💰 **Savings** | Bank accounts | 4% |
| 🛡️ **Emergency Fund** | Emergency savings | 4% |
| 📱 **Personal Assets** | Cars, electronics, etc. | -7.5% |

## 🏗️ Technical Architecture

### Frontend
- **Vanilla JavaScript**: No frameworks, lightweight and fast
- **Tailwind CSS**: Utility-first CSS framework
- **Feather Icons**: Beautiful, lightweight icons
- **Service Worker**: Offline functionality and caching

### Storage & Security
- **LocalStorage**: Browser-based data persistence
- **CryptoJS**: Client-side encryption
- **IndexedDB**: For large data storage (future enhancement)

### Project Structure
```
networth/
├── index.html              # Main application UI
├── manifest.json           # PWA configuration
├── service-worker.js       # Offline functionality
├── styles.css             # Custom styles
├── js/
│   ├── app.js             # Main application logic
│   ├── storage.js         # Data persistence layer
│   ├── calculations.js    # Net worth calculations
│   ├── assetCategories.js # Asset type definitions
│   ├── ui.js              # UI interactions
│   └── components/
│       ├── dashboard.js   # Main dashboard component
│       ├── assetForm.js   # Asset input form
│       ├── projection.js  # Growth projections
│       └── slider.js      # Custom slider components
└── assets/
    ├── icon-192x192.png   # PWA icons
    ├── icon-512x512.png
    └── logo.svg
```

## 🔧 Development

### Prerequisites
- Modern web browser with ES6+ support
- Local web server (for CORS and service worker)

### Building
No build process required! This is a vanilla JavaScript application.

### Key Components

#### 1. StorageService (`js/storage.js`)
Handles all data persistence with encryption:
```javascript
// Save encrypted asset data
storageService.saveAssets(assets);

// Retrieve and decrypt data
const assets = storageService.getAssets();
```

#### 2. CalculationsService (`js/calculations.js`)
Manages all financial calculations:
```javascript
// Calculate total net worth
const netWorth = calculationsService.calculateNetWorth();

// Project future value
const projection = calculationsService.projectNetWorth(12);
```

#### 3. Dashboard Component (`js/components/dashboard.js`)
Main UI component managing the overview screen.

### Adding New Asset Categories
1. Add category definition to `assetCategories.js`
2. Update calculation logic in `calculations.js`
3. Test with various input scenarios

## 🎯 Future Enhancements

- [ ] **Data Export/Import**: Backup and restore functionality
- [ ] **Multiple Currencies**: Support for international users
- [ ] **Chart Visualizations**: Interactive graphs and charts
- [ ] **Goal Tracking**: Set and track financial goals
- [ ] **Debt Tracking**: Add liability management
- [ ] **Transaction History**: Track asset value changes over time
- [ ] **Portfolio Rebalancing**: Asset allocation suggestions

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📜 License

This project is open source and available under the [MIT License](LICENSE).

## 📞 Support

If you have any questions or need help:
- Open an [issue](https://github.com/thisisprabha/networth/issues)
- Reach out to [@thisisprabha](https://github.com/thisisprabha)

## ⭐ Star History

If this project helped you track your wealth, please consider giving it a star! ⭐

---

**Built with ❤️ for financial privacy and independence**

> **Note**: This application stores all data locally on your device. Please ensure you backup your data regularly. The growth rate assumptions are based on historical averages and actual results may vary. 