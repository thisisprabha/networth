/**
 * Projection Component
 * Handles visualization of net worth projections
 */
class ProjectionChart {
  constructor(calculationsService) {
    this.calculationsService = calculationsService;
    this.chart = null;
  }

  /**
   * Initialize projection chart
   */
  init() {
    // Create projection chart
    this.createChart();
  }

  /**
   * Create the projection chart
   */
  createChart() {
    const ctx = document.getElementById("projection-chart").getContext("2d");

    // Get projection data
    const projectionData = this.calculationsService.projectNetWorth(12);

    // Extract labels (months) and values
    const labels = projectionData.map((point, index) => {
      if (index === 0) return "Now";
      if (index === projectionData.length - 1) return "1 Year";
      return `${index} mon`;
    });

    const values = projectionData.map((point) => point.value);

    // Check if dark mode
    const isDarkMode =
      document.documentElement.classList.contains("dark") ||
      window.matchMedia("(prefers-color-scheme: dark)").matches;

    const gridColor = isDarkMode
      ? "rgba(255, 255, 255, 0.1)"
      : "rgba(0, 0, 0, 0.1)";
    const textColor = isDarkMode
      ? "rgba(255, 255, 255, 0.7)"
      : "rgba(0, 0, 0, 0.7)";

    // Create chart
    this.chart = new Chart(ctx, {
      type: "line",
      data: {
        labels: labels,
        datasets: [
          {
            label: "Projected Net Worth",
            data: values,
            backgroundColor: "rgba(0, 0, 0, 0.1)",
            borderColor: isDarkMode
              ? "rgba(255, 255, 255, 0.8)"
              : "rgba(0, 0, 0, 0.8)",
            borderWidth: 2,
            tension: 0.3,
            pointRadius: 3,
            pointBackgroundColor: isDarkMode ? "#fff" : "#000",
            fill: true,
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false,
          },
          tooltip: {
            callbacks: {
              label: (context) => {
                const value = context.parsed.y;
                return `crrency(value)}`;
                // ₹
              },
            },
          },
        },
        scales: {
          x: {
            grid: {
              color: gridColor,
              drawBorder: false,
            },
            ticks: {
              color: textColor,
              font: {
                size: 10,
              },
            },
          },
          y: {
            grid: {
              color: gridColor,
              drawBorder: false,
            },
            ticks: {
              color: textColor,
              font: {
                size: 10,
              },
              callback: (value) => {
                if (value >= 10000000) {
                  return `${(value / 10000000).toFixed(1)}Cr`;
                } else if (value >= 100000) {
                  return `${(value / 100000).toFixed(1)}L`;
                } else if (value >= 1000) {
                  return `${(value / 1000).toFixed(0)}K`;
                }
                return `${value}`;
              },
            },
            beginAtZero: true,
          },
        },
      },
    });
  }

  /**
   * Update the projection chart with new data
   */
  update() {
    if (this.chart) {
      this.chart.destroy();
    }

    this.createChart();
  }
}
