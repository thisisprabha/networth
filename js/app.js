/**
 * Net Worth - Main Application
 * A private, offline-first net worth tracking application
 */

document.addEventListener("DOMContentLoaded", () => {
  // Check if storageService and calculationsService are available
  if (
    typeof storageService === "undefined" ||
    typeof calculationsService === "undefined"
  ) {
    console.error(
      "ERROR: storageService or calculationsService is not available. App cannot initialize."
    );
    const appContainer = document.getElementById("app");
    if (appContainer) {
      appContainer.innerHTML =
        '<div class="p-4 text-red-500 text-center">Error: Essential services failed to load. Cannot start application.</div>';
    }
    return;
  }

  // PIN Authentication Logic
  const PIN_KEY = "app_pin";
  const appContainer = document.getElementById("app");

  // Store original HTML to restore after PIN
  const originalAppHtml = appContainer.innerHTML;

  function showPinPrompt(isNewPin = false) {
    appContainer.innerHTML = `
      <div class="pin-prompt flex flex-col items-center justify-center h-screen bg-gray-900 text-white">
        <h2 class="text-2xl mb-4">${
          isNewPin ? "First time? Set 4-Digit PIN" : "Enter 4-Digit PIN"
        }</h2>
        <input
          type="password"
          id="pin-input"
          maxlength="4"
          class="p-2 text-center text-white rounded mb-4 w-24"
          placeholder="****"
          inputmode="numeric"
        />
        ${
          isNewPin
            ? "<span class=text-gray-500 text-center mb-2>Make this easy to remember. Dont fuck it up.</span>"
            : "<span class=text-gray-500 text-center p-2></span>"
        }
        <button id="pin-submit" class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
          ${isNewPin ? "Set PIN" : "Submit"} 
        </button>
        <p id="pin-error" class="text-red-500 mt-2 hidden">Invalid PIN. Try again.</p>
      </div>
    `;

    const pinInput = document.getElementById("pin-input");
    const pinSubmit = document.getElementById("pin-submit");
    const pinError = document.getElementById("pin-error");

    pinSubmit.addEventListener("click", () => {
      const enteredPin = pinInput.value;
      if (!/^\d{4}$/.test(enteredPin)) {
        pinError.classList.remove("hidden");
        return;
      }

      if (isNewPin) {
        // Save PIN (add CryptoJS here if used)
        localStorage.setItem(PIN_KEY, enteredPin); // Replace with CryptoJS if installed
        initializeApp();
      } else {
        const storedPin = localStorage.getItem(PIN_KEY);
        if (enteredPin === storedPin) {
          // Replace with CryptoJS if installed
          initializeApp();
        } else {
          pinError.classList.remove("hidden");
          pinInput.value = "";
        }
      }
    });

    pinInput.focus();
    pinInput.addEventListener("keypress", (e) => {
      if (e.key === "Enter") pinSubmit.click();
    });
  }

  function initializeApp() {
    // Restore original HTML instead of clearing
    appContainer.innerHTML =
      originalAppHtml ||
      `
      <div id="app">
        <div id="assets-view" class="hidden"></div>
        <!-- Add other static elements if needed -->
      </div>
    `;

    function renderFullAssetList() {
      const fullAssetList = document.getElementById("full-asset-list");
      if (!fullAssetList) {
        console.error('Element with ID "full-asset-list" not found.');
        // Create it if missing
        const assetsView = document.getElementById("assets-view");
        if (assetsView) {
          assetsView.innerHTML = '<div id="full-asset-list"></div>';
          return renderFullAssetList();
        }
        return;
      }

      const assets = storageService.getAssets();
      fullAssetList.innerHTML = "";

      if (assets.length === 0) {
        const emptyState = document.createElement("div");
        emptyState.className = "py-6 text-center text-gray-500";
        emptyState.textContent =
          "No assets added yet. Add your first asset with the + button.";
        fullAssetList.appendChild(emptyState);
      } else {
        assets.sort((a, b) => {
          const valueA = calculationsService.getAssetValue(a);
          const valueB = calculationsService.getAssetValue(b);
          return valueB - valueA;
        });

        assets.forEach((asset) => {
          const assetValue = calculationsService.getAssetValue(asset);
          const assetCard = document.createElement("div");
          assetCard.className =
            "asset-card flex justify-between items-center cursor-pointer hover:bg-gray-800";
          assetCard.dataset.assetId = asset.id;

          const assetInfo = document.createElement("div");
          assetInfo.className = "flex items-center overflow-hidden mr-2";

          const assetIcon = document.createElement("div");
          assetIcon.className = `${asset.color} mr-3 flex-shrink-0`;
          assetIcon.innerHTML = `<i data-feather="${asset.icon}" class="h-5 w-5"></i>`;

          const assetDetails = document.createElement("div");
          assetDetails.className = "overflow-hidden";

          const assetName = document.createElement("div");
          assetName.className = "font-medium truncate";
          assetName.textContent = asset.name;
          assetDetails.appendChild(assetName);

          if (asset.values && asset.values.assetName) {
            const assetDesc = document.createElement("div");
            assetDesc.className = "text-xs text-gray-400 truncate";
            assetDesc.textContent = asset.values.assetName;
            assetDetails.appendChild(assetDesc);
          }

          assetInfo.appendChild(assetIcon);
          assetInfo.appendChild(assetDetails);

          const assetValueEl = document.createElement("div");
          assetValueEl.className =
            "font-medium text-right ml-2 whitespace-nowrap flex-shrink-0";
          if (typeof calculationsService.formatCurrency === "function") {
            assetValueEl.textContent =
              calculationsService.formatCurrency2(assetValue);
          } else {
            assetValueEl.textContent = `${calculationsService.formatCurrency(
              assetValue
            )}`;
            console.warn(
              "formatIndianCurrency function not found on calculationsService."
            );
          }

          assetCard.appendChild(assetInfo);
          assetCard.appendChild(assetValueEl);

          assetCard.addEventListener("click", () => {
            dashboard.editAsset(asset.id);
          });

          fullAssetList.appendChild(assetCard);
        });
      }

      if (typeof feather !== "undefined") {
        feather.replace();
      }
    }

    // Initialize components
    const dashboard = new Dashboard(storageService, calculationsService);
    const assetForm = new AssetForm(storageService, (savedAsset) => {
      console.log("AssetForm onSave triggered.");
      dashboard.refresh();
      const assetsView = document.getElementById("assets-view");
      if (assetsView && !assetsView.classList.contains("hidden")) {
        console.log("Assets view is visible, refreshing full list.");
        renderFullAssetList();
      }
    });

    dashboard.setAssetForm(assetForm);

    // Ensure form HTML exists before initializing
    const formContainer = document.getElementById("asset-form-container");
    if (!formContainer) {
      console.warn("Asset form container not found, creating one.");
      const newFormContainer = document.createElement("div");
      newFormContainer.id = "asset-form-container";
      newFormContainer.className = "hidden"; // Hide by default
      appContainer.appendChild(newFormContainer);
    }

    dashboard.init();

    // Add Import/Export UI (if previously added)
    const settingsSection = document.createElement("div");
    settingsSection.className = "p-4 border-t border-gray-700 text-center";
    settingsSection.innerHTML = `
      <h3 class="text-gray-600 text-center mb-2 text-center">Backup & Restore</h3>
      <span>
      <button id="export-csv" class="text-gray-500 text-center mb-2 text-white px-4 py-2 rounded mr-2 hover:bg-blue-600">
        ⍈ Export
      </button>
      <label class="text-gray-500 text-center mb-2 text-white px-4 py-2 rounded cursor-pointer hover:bg-green-600">
        ⍇ Import
        <input type="file" id="import-csv" accept=".csv" class="hidden">
      </label> </span>
      <p id="import-error" class="text-red-500 mt-2 hidden"></p>
    `;
    appContainer.appendChild(settingsSection);

    const exportCsvBtn = document.getElementById("export-csv");
    const importCsvInput = document.getElementById("import-csv");
    const importError = document.getElementById("import-error");

    exportCsvBtn.addEventListener("click", () => {
      storageService.exportToCSV();
    });

    importCsvInput.addEventListener("change", (e) => {
      const file = e.target.files[0];
      if (file) {
        storageService
          .importFromCSV(file)
          .then((count) => {
            dashboard.refresh();
            renderFullAssetList();
            importError.classList.add("hidden");
            alert(`${count} assets imported successfully!`);
          })
          .catch((error) => {
            importError.textContent = `Import failed: ${error.message}`;
            importError.classList.remove("hidden");
          });
        e.target.value = "";
      }
    });

    // Rest of the original logic
    const addAssetBtn = document.getElementById("add-asset-btn");
    const addAssetBtnList = document.getElementById("add-asset-btn-list");

    if (addAssetBtn) {
      addAssetBtn.addEventListener("click", () => {
        assetForm.showAddForm();
      });
    }

    if (addAssetBtnList) {
      addAssetBtnList.addEventListener("click", () => {
        assetForm.showAddForm();
      });
    }

    const viewAssetsBtn = document.getElementById("view-assets-btn");
    const viewOverviewBtn = document.getElementById("view-overview-btn");
    const closeAssetsView = document.getElementById("close-assets-view");
    const assetsView = document.getElementById("assets-view");

    if (viewAssetsBtn && assetsView) {
      viewAssetsBtn.addEventListener("click", () => {
        renderFullAssetList();
        assetsView.classList.remove("hidden");
        viewAssetsBtn.classList.remove("text-gray-500");
        viewAssetsBtn.classList.add("text-white");
        viewOverviewBtn.classList.remove("text-white");
        viewOverviewBtn.classList.add("text-gray-500");
      });
    }

    if (viewOverviewBtn && assetsView) {
      viewOverviewBtn.addEventListener("click", () => {
        assetsView.classList.add("hidden");
        viewOverviewBtn.classList.remove("text-gray-500");
        viewOverviewBtn.classList.add("text-white");
        viewAssetsBtn.classList.remove("text-white");
        viewAssetsBtn.classList.add("text-gray-500");
      });
    }

    if (closeAssetsView && assetsView) {
      closeAssetsView.addEventListener("click", () => {
        assetsView.classList.add("hidden");
        viewOverviewBtn.classList.remove("text-gray-500");
        viewOverviewBtn.classList.add("text-white");
        viewAssetsBtn.classList.remove("text-white");
        viewAssetsBtn.classList.add("text-gray-500");
      });
    }

    if (typeof feather !== "undefined") {
      feather.replace();
    }
  }

  // Check if PIN exists
  const storedPin = localStorage.getItem(PIN_KEY);
  if (!storedPin) {
    showPinPrompt(true);
  } else {
    showPinPrompt(false);
  }
});
