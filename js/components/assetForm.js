/**
 * Asset Form Component
 * Handles creation and editing of asset entries
 */
class AssetForm {
  constructor(storageService, onSave = null) {
    this.storageService = storageService;
    this.onSave = onSave;
    this.currentAsset = null;
    this.sliders = {};
    this.formContainer = document.getElementById("asset-modal");

    // Initialize form HTML
    this.initForm();
  }

  /**
   * Initialize form HTML
   */
  initForm() {
    if (!this.formContainer) {
      console.error("Asset modal container (#asset-modal) not found.");
      return;
    }

    // Render form HTML
    this.formContainer.innerHTML = `
      <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4">
        <div class="bg-white dark:bg-gray-800 rounded-lg p-6 w-full max-w-md">
          <h2 id="modal-title" class="text-xl font-bold mb-4 text-gray-900 dark:text-white">Add Asset</h2>
          <form id="asset-form">
            <div class="mb-4">
              <label for="asset-category" class="block text-sm font-medium mb-1 text-gray-900 dark:text-white">Category</label>
              <select id="asset-category" class="w-full p-2 border border-gray-300 dark:border-gray-700 dark:bg-gray-800 rounded-md text-gray-900 dark:text-white">
                <option value="">Select category</option>
              </select>
            </div>
            <div id="dynamic-fields" class="mb-4"></div>
            <div class="flex justify-end gap-2">
              <button type="button" id="cancel-asset" class="px-4 py-2 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-700 rounded-md">Cancel</button>
              <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600">Save</button>
              <button id="delete-asset" class="hidden px-4 py-2 bg-red-500 text-white rounded-md hover:bg-red-600">Delete</button>
            </div>
          </form>
        </div>
      </div>
    `;

    // Populate category dropdown
    this.populateCategoryDropdown();

    // Initialize event listeners after form exists
    this.initEventListeners();
  }

  /**
   * Set up event listeners for asset form
   */
  initEventListeners() {
    const form = document.getElementById("asset-form");
    const categorySelect = document.getElementById("asset-category");
    const deleteButton = document.getElementById("delete-asset");
    const cancelButton = document.getElementById("cancel-asset");

    if (!form || !categorySelect || !deleteButton || !cancelButton) {
      console.warn("Form elements not found, skipping event listeners.");
      return;
    }

    // Handle category selection change
    categorySelect.addEventListener("change", () => {
      const category = categorySelect.value;
      this.renderDynamicFields(category);
    });

    // Handle form submission
    form.addEventListener("submit", (e) => {
      e.preventDefault();
      this.saveAsset();
    });

    // Handle asset deletion
    deleteButton.addEventListener("click", (e) => {
      e.preventDefault();
      if (confirm("Are you sure you want to delete this asset?")) {
        this.deleteAsset();
      }
    });

    // Handle cancel button
    cancelButton.addEventListener("click", () => {
      this.closeForm();
    });
  }

  /**
   * Populate asset category dropdown
   */
  populateCategoryDropdown() {
    const categorySelect = document.getElementById("asset-category");
    if (!categorySelect) {
      console.warn("asset-category select not found.");
      return;
    }

    // Clear existing options except the first one
    while (categorySelect.options.length > 1) {
      categorySelect.remove(1);
    }

    // Add options for each asset category
    for (const [key, category] of Object.entries(assetCategories)) {
      const option = document.createElement("option");
      option.value = key;
      option.textContent = category.name;
      categorySelect.appendChild(option);
    }
  }

  /**
   * Render form fields based on selected asset category
   * @param {String} category Asset category key
   */
  renderDynamicFields(category) {
    const dynamicFields = document.getElementById("dynamic-fields");
    if (!dynamicFields) return;

    dynamicFields.innerHTML = "";
    this.sliders = {};

    if (!category || !assetCategories[category]) {
      return;
    }

    const categoryConfig = assetCategories[category];

    // Create field for each defined input in the category
    categoryConfig.fields.forEach((field) => {
      const fieldContainer = document.createElement("div");
      fieldContainer.className = "mb-4";

      const label = document.createElement("label");
      label.htmlFor = field.id;
      label.className =
        "block text-sm font-medium mb-1 text-gray-900 dark:text-white";
      label.textContent = field.label;
      fieldContainer.appendChild(label);

      // Create input based on field type
      switch (field.type) {
        case "slider":
          const slider = new Slider({
            id: field.id,
            min: field.min,
            max: field.max,
            step: field.step,
            defaultValue: this.getCurrentValue(field.id, field.defaultValue),
            format: field.format,
          });
          fieldContainer.appendChild(slider.render());
          this.sliders[field.id] = slider;
          break;

        case "number":
          const numberInput = document.createElement("input");
          numberInput.type = "number";
          numberInput.id = field.id;
          numberInput.name = field.id;
          numberInput.className =
            "w-full p-2 border border-gray-300 dark:border-gray-700 dark:bg-gray-800 rounded-md text-gray-900 dark:text-white";
          numberInput.min = field.min !== undefined ? field.min : "";
          numberInput.max = field.max !== undefined ? field.max : "";
          numberInput.step = field.step || 1;
          numberInput.value = this.getCurrentValue(
            field.id,
            field.defaultValue
          );
          fieldContainer.appendChild(numberInput);
          break;

        case "text":
          const textInput = document.createElement("input");
          textInput.type = "text";
          textInput.id = field.id;
          textInput.name = field.id;
          textInput.className =
            "w-full p-2 border border-gray-300 dark:border-gray-700 dark:bg-gray-800 rounded-md text-gray-900 dark:text-white";
          textInput.value = this.getCurrentValue(field.id, field.defaultValue);
          fieldContainer.appendChild(textInput);
          break;

        case "date":
          const dateInput = document.createElement("input");
          dateInput.type = "date";
          dateInput.id = field.id;
          dateInput.name = field.id;
          dateInput.className =
            "w-full p-2 border border-gray-300 dark:border-gray-700 dark:bg-gray-800 rounded-md text-gray-900 dark:text-white";
          dateInput.value = this.getCurrentValue(field.id, field.defaultValue);
          fieldContainer.appendChild(dateInput);
          break;

        case "select":
          const select = document.createElement("select");
          select.id = field.id;
          select.name = field.id;
          select.className =
            "w-full p-2 border border-gray-300 dark:border-gray-700 dark:bg-gray-800 rounded-md text-gray-900 dark:text-white";

          field.options.forEach((option) => {
            const optionElement = document.createElement("option");
            optionElement.value = option.value;
            optionElement.textContent = option.label;
            select.appendChild(optionElement);
          });

          if (this.currentAsset && this.currentAsset.values[field.id]) {
            select.value = this.currentAsset.values[field.id];
          }

          select.addEventListener("change", (e) => {
            if (field.id === "assetType") {
              const selectedOption = field.options.find(
                (opt) => opt.value === e.target.value
              );
              const valueSlider = this.sliders["assetValue"];
              if (valueSlider && selectedOption) {
                valueSlider.setValue(selectedOption.defaultValue);
              }
            }
          });

          fieldContainer.appendChild(select);
          break;
      }

      dynamicFields.appendChild(fieldContainer);
    });

    // Add growth rate configuration if available
    if (categoryConfig.growthRate) {
      const growthRateContainer = document.createElement("div");
      growthRateContainer.className =
        "mb-4 mt-6 pt-4 border-t border-gray-200 dark:border-gray-700";

      const growthRateLabel = document.createElement("label");
      growthRateLabel.htmlFor = "growthRate";
      growthRateLabel.className =
        "block text-sm font-medium mb-1 text-gray-900 dark:text-white";
      growthRateLabel.textContent = "Annual Growth Rate (%)";

      const growthRateInput = document.createElement("input");
      growthRateInput.type = "number";
      growthRateInput.id = "growthRate";
      growthRateInput.name = "growthRate";
      growthRateInput.className =
        "w-full p-2 border border-gray-300 dark:border-gray-700 dark:bg-gray-800 rounded-md text-gray-900 dark:text-white";
      growthRateInput.step = 0.1;

      if (categoryConfig.growthRate.min !== undefined) {
        growthRateInput.min = categoryConfig.growthRate.min;
      }

      if (categoryConfig.growthRate.max !== undefined) {
        growthRateInput.max = categoryConfig.growthRate.max;
      }

      const settings = this.storageService.getSettings();
      growthRateInput.value =
        settings.growthRates[category] || categoryConfig.growthRate.default;

      growthRateContainer.appendChild(growthRateLabel);
      growthRateContainer.appendChild(growthRateInput);

      const growthNote = document.createElement("div");
      growthNote.className = "text-xs text-gray-500 dark:text-gray-400 mt-1";
      growthNote.textContent = "Used for projection calculations only";
      growthRateContainer.appendChild(growthNote);

      dynamicFields.appendChild(growthRateContainer);
    }
  }

  /**
   * Get current value for a field when editing an asset
   * @param {String} fieldId Field identifier
   * @param {*} defaultValue Default value if not found
   * @returns {*} Current or default value
   */
  getCurrentValue(fieldId, defaultValue) {
    if (
      this.currentAsset &&
      this.currentAsset.values &&
      this.currentAsset.values[fieldId] !== undefined
    ) {
      return this.currentAsset.values[fieldId];
    }
    return defaultValue;
  }

  /**
   * Show form for creating a new asset
   */
  showAddForm() {
    const modal = document.getElementById("asset-modal");
    const modalTitle = document.getElementById("modal-title");
    const categorySelect = document.getElementById("asset-category");
    const dynamicFields = document.getElementById("dynamic-fields");
    const deleteButton = document.getElementById("delete-asset");

    if (
      !modal ||
      !modalTitle ||
      !categorySelect ||
      !dynamicFields ||
      !deleteButton
    ) {
      console.error("Form elements missing in showAddForm.");
      return;
    }

    // Reset form
    this.currentAsset = null;
    modalTitle.textContent = "Add Asset";
    categorySelect.value = "";
    dynamicFields.innerHTML = "";
    deleteButton.classList.add("hidden");

    // Populate dropdown (redundant if initForm already did, but safe)
    this.populateCategoryDropdown();

    // Show modal
    modal.classList.remove("hidden");
  }

  /**
   * Show form for editing an existing asset
   * @param {Object} asset Asset to edit
   */
  showEditForm(asset) {
    const modal = document.getElementById("asset-modal");
    const modalTitle = document.getElementById("modal-title");
    const categorySelect = document.getElementById("asset-category");
    const deleteButton = document.getElementById("delete-asset");

    if (!modal || !modalTitle || !categorySelect || !deleteButton) {
      console.error("Form elements missing in showEditForm.");
      return;
    }

    // Set current asset and form title
    this.currentAsset = asset;
    modalTitle.textContent = "Edit Asset";
    deleteButton.classList.remove("hidden");

    // Populate dropdown
    this.populateCategoryDropdown();

    // Set category and render fields
    categorySelect.value = asset.category;
    this.renderDynamicFields(asset.category);

    // Show modal
    modal.classList.remove("hidden");
  }

  /**
   * Close the asset form
   */
  closeForm() {
    const modal = document.getElementById("asset-modal");
    if (modal) {
      modal.classList.add("hidden");
    }
    this.currentAsset = null;
  }

  /**
   * Save current asset data
   */
  saveAsset() {
    const categorySelect = document.getElementById("asset-category");
    const category = categorySelect.value;

    if (!category) {
      alert("Choose what you own");
      return;
    }

    const values = {};
    const categoryConfig = assetCategories[category];
    categoryConfig.fields.forEach((field) => {
      const element = document.getElementById(field.id);
      if (field.type === "slider" && this.sliders[field.id]) {
        values[field.id] = this.sliders[field.id].getValue();
      } else if (element) {
        let value = element.value;
        if (field.type === "number" || element.type === "number") {
          value = Number(value);
        }
        values[field.id] = value;
      }
    });

    const asset = {
      id: this.currentAsset
        ? this.currentAsset.id
        : this.storageService.generateId(),
      category,
      name: categoryConfig.name,
      icon: categoryConfig.icon,
      color: categoryConfig.color,
      values,
      createdAt: this.currentAsset
        ? this.currentAsset.createdAt
        : new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    const growthRateInput = document.getElementById("growthRate");
    if (growthRateInput && categoryConfig.growthRate) {
      const settings = this.storageService.getSettings();
      if (!settings.growthRates) settings.growthRates = {};
      settings.growthRates[category] = Number(growthRateInput.value);
      this.storageService.saveSettings(settings);
    }

    const savedAsset = this.storageService.saveAsset(asset);
    this.closeForm();

    if (typeof this.onSave === "function") {
      this.onSave(savedAsset);
    }
  }

  /**
   * Delete current asset
   */
  deleteAsset() {
    if (!this.currentAsset) return;

    const assetIdToDelete = this.currentAsset.id;
    const deleted = this.storageService.deleteAsset(assetIdToDelete);

    if (deleted) {
      this.closeForm();
      if (typeof this.onSave === "function") {
        this.onSave();
      }
    } else {
      alert("Failed to delete asset.");
    }
  }
}
