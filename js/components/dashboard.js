/**
 * Dashboard Component
 * Manages the main dashboard view and asset list
 */
class Dashboard {
  constructor(storageService, calculationsService) {
    this.storageService = storageService;
    this.calculationsService = calculationsService;

    // Track if component is mounted
    this.isMounted = false;
  }

  /**
   * Initialize dashboard component
   */
  init() {
    // Render assets
    this.renderAssets();

    // Update summary data
    this.updateSummary();

    // Mark as mounted
    this.isMounted = true;
  }

  /**
   * Render all assets in the dashboard
   */
  renderAssets() {
    const assetList = document.getElementById("asset-list");
    const assets = this.storageService.getAssets();

    // Clear current list
    assetList.innerHTML = "";

    if (assets.length === 0) {
      // Show empty state
      const emptyState = document.createElement("div");
      emptyState.className = "py-4 text-center";
      emptyState.textContent = "No assets added yet";
      assetList.appendChild(emptyState);
      return;
    }

    // Sort assets by value (descending)
    assets.sort((a, b) => {
      const valueA = this.calculationsService.getAssetValue(a);
      const valueB = this.calculationsService.getAssetValue(b);
      return valueB - valueA;
    });

    // Get top 3 assets for the overview
    const topAssets = assets.slice(0, 3);

    // Create simple asset cards for the overview
    topAssets.forEach((asset) => {
      const assetValue = this.calculationsService.getAssetValue(asset);

      const assetCard = document.createElement("div");
      assetCard.className =
        "asset-card flex justify-between items-center cursor-pointer";
      assetCard.dataset.assetId = asset.id;

      // Asset info (left side)
      const assetInfo = document.createElement("div");
      assetInfo.className = "flex items-center";

      const assetIcon = document.createElement("div");
      assetIcon.className = `${asset.color} mr-3`;
      assetIcon.innerHTML = `<i data-feather="${asset.icon}" class="h-5 w-5"></i>`;

      const assetName = document.createElement("div");
      assetName.className = "text-gray-400";
      assetName.textContent = asset.name;

      assetInfo.appendChild(assetIcon);
      assetInfo.appendChild(assetName);

      // Asset value (right side)
      const assetValueEl = document.createElement("div");
      assetValueEl.className = "text-gray-300 font-medium";
      assetValueEl.textContent = `${this.calculationsService.formatCurrency2(
        assetValue
      )}`;

      // Assemble card
      assetCard.appendChild(assetInfo);
      assetCard.appendChild(assetValueEl);

      // Add click event to edit asset
      assetCard.addEventListener("click", () => {
        this.editAsset(asset.id);
      });

      // Add to list
      assetList.appendChild(assetCard);
    });

    // Add "View All" link if there are more than 3 assets
    if (assets.length > 3) {
      const viewAllLink = document.createElement("div");
      viewAllLink.className = "text-center mt-3 text-green-500";
      viewAllLink.textContent = `+ ${assets.length - 3} more assets`;
      viewAllLink.style.cursor = "pointer";

      viewAllLink.addEventListener("click", () => {
        // Trigger view assets button click
        document.getElementById("view-assets-btn").click();
      });

      assetList.appendChild(viewAllLink);
    }

    // Initialize Feather icons
    feather.replace();
  }

  /**
   * Update the summary section with current calculations
   */
  updateSummary() {
    const currentNetWorthEl = document.getElementById("current-net-worth");
    const projectedNetWorthEl = document.getElementById("projected-net-worth");
    // Target the span inside the button if it exists, otherwise the button itself
    const addAssetBtnContent =
      document.querySelector("#add-asset-btn span") ||
      document.getElementById("add-asset-btn");
    const addAssetBtnIcon = document.querySelector("#add-asset-btn i"); // Get the icon
    // ₹
    // Calculate current net worth
    const currentNetWorth = this.calculationsService.calculateNetWorth();
    currentNetWorthEl.textContent =
      this.calculationsService.formatCurrency(currentNetWorth); // Use standard formatting here

    // Calculate projected net worth (1 year)
    const projectedNetWorth = this.calculationsService.getOneYearProjection();
    projectedNetWorthEl.textContent =
      this.calculationsService.formatCurrency(projectedNetWorth); // Use standard formatting here

    // --- CHANGE BUTTON CONTENT CALCULATION ---
    let buttonText = "0"; // Default text
    let iconClass = "arrow-up"; // Default icon
    let textColor = "text-green-500"; // Default color (used indirectly via icon class later)

    if (currentNetWorth > 0) {
      const growth = projectedNetWorth - currentNetWorth;
      const percentageGrowth = (growth / currentNetWorth) * 100;

      if (Math.abs(percentageGrowth) < 0.1) {
        buttonText = `~0%`; // Show approx zero for very small changes
        iconClass = "minus";
        textColor = "text-amber-500";
      } else if (percentageGrowth >= 0) {
        buttonText = `+${percentageGrowth.toFixed(1)}%`;
        iconClass = "arrow-up";
        textColor = "text-green-500";
      } else {
        buttonText = `${percentageGrowth.toFixed(1)}%`; // Negative sign included
        iconClass = "arrow-down";
        textColor = "text-red-500";
      }
    } else if (projectedNetWorth > 0) {
      buttonText = `Proj: ${this.calculationsService.formatCurrency(
        projectedNetWorth
      )}`; // Show projection if current is 0 but projection > 0
    } else {
      buttonText = "Add Asset"; // Fallback if no value and no projection
      iconClass = "plus";
    }

    if (addAssetBtnContent) {
      addAssetBtnContent.textContent = buttonText;
    }
    if (addAssetBtnIcon) {
      addAssetBtnIcon.setAttribute("data-feather", iconClass); // Change icon type
      // Update icon color if needed (assuming icon color matches text color logic)
      addAssetBtnIcon.classList.remove(
        "text-green-500",
        "text-red-500",
        "text-amber-500"
      ); // Remove old colors
      addAssetBtnIcon.classList.add(textColor); // Add new color
      feather.replace(); // Re-render icons
    }
    // --- END OF BUTTON CONTENT CHANGE ---
  }

  /**
   * Refresh dashboard data
   */
  refresh() {
    this.renderAssets();
    this.updateSummary();
  }

  /**
   * Show edit form for an asset
   * @param {String} assetId ID of the asset to edit
   */
  editAsset(assetId) {
    const assets = this.storageService.getAssets();
    const asset = assets.find((a) => a.id === assetId);

    if (asset && this.assetForm) {
      this.assetForm.showEditForm(asset);
    }
  }

  /**
   * Set reference to the asset form component
   * @param {AssetForm} assetForm AssetForm instance
   */
  setAssetForm(assetForm) {
    this.assetForm = assetForm;
  }
}
