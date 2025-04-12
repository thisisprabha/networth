/**
 * Custom Slider Component
 * Creates an interactive slider with a value display
 */
class Slider {
  /**
   * Create a new slider component
   * @param {Object} options Configuration options
   * @param {String} options.id Element ID
   * @param {Number} options.min Minimum value
   * @param {Number} options.max Maximum value
   * @param {Number} options.step Step increment
   * @param {Number} options.defaultValue Initial value
   * @param {String} options.format Optional formatting ('currency' or null)
   * @param {Function} options.onChange Optional callback when value changes
   */
  constructor(options) {
    this.options = {
      min: 0,
      max: 100,
      step: 1,
      defaultValue: 0,
      format: null,
      onChange: null,
      ...options,
    };

    this.value = this.options.defaultValue;
  }

  /**
   * Render the slider component
   * @returns {HTMLElement} The slider container element
   */
  render() {
    // Create container
    const container = document.createElement("div");
    container.className = "slider-container my-2";

    // Create value display
    const valueDisplay = document.createElement("div");
    valueDisplay.className = "flex justify-between text-sm mb-1";

    const currentValue = document.createElement("span");
    currentValue.className = "font-medium";
    currentValue.textContent = this.formatValue(this.value);

    const maxValue = document.createElement("span");
    maxValue.className = "text-gray-500 dark:text-gray-400 text-xs";
    maxValue.textContent = this.formatValue(this.options.max);

    valueDisplay.appendChild(currentValue);
    valueDisplay.appendChild(maxValue);

    // Create slider
    const slider = document.createElement("input");
    slider.type = "range";
    slider.id = this.options.id;
    slider.name = this.options.id;
    slider.className = "custom-slider w-full";
    slider.min = this.options.min;
    slider.max = this.options.max;
    slider.step = this.options.step;
    slider.value = this.value;

    // Add event listeners
    slider.addEventListener("input", (e) => {
      this.value = Number(e.target.value);
      currentValue.textContent = this.formatValue(this.value);

      if (typeof this.options.onChange === "function") {
        this.options.onChange(this.value);
      }
    });

    // Assemble component
    container.appendChild(valueDisplay);
    container.appendChild(slider);

    return container;
  }

  /**
   * Format slider value based on options
   * @param {Number} value Value to format
   * @returns {String} Formatted value
   */
  formatValue(value) {
    if (this.options.format === "currency") {
      return (
        "₹" +
        new Intl.NumberFormat("en-IN", {
          maximumFractionDigits: 0,
        }).format(value)
      );
    }

    return value.toString();
  }

  /**
   * Set slider value programmatically
   * @param {Number} value New value
   */
  setValue(value) {
    this.value = Number(value);

    const slider = document.getElementById(this.options.id);
    if (slider) {
      slider.value = this.value;

      // Update display value
      const container = slider.parentElement;
      const valueDisplay = container.querySelector(".font-medium");
      if (valueDisplay) {
        valueDisplay.textContent = this.formatValue(this.value);
      }
    }
  }

  /**
   * Get current slider value
   * @returns {Number} Current value
   */
  getValue() {
    return this.value;
  }
}
