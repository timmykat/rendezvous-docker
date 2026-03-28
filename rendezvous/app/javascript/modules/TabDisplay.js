export class TabDisplay extends HTMLElement {
  connectedCallback() {
    this.addEventListener("click", this.tabHandler);
    this.setupTabs();
  }

  disconnectedCallback() {
    this.removeEventListener("click", this.tabHandler);
  }

  setupTabs() {
    const contents = this.querySelectorAll(".tab-content");

    // Set summary tab to visible
    contents.forEach((panel, index) => {
      panel.hidden = index !== 0;
    });
  }

  tabHandler = (e) => {
    const btn = e.target.closest("[data-tab]");
    if (!btn) return;

    const container = btn.closest("[data-tabbed]");
    this.activateTab(container, btn.dataset.tab);
  };

  activateTab(container, target) {
    // Toggle content visibility
    container.querySelectorAll("[data-tab-content]").forEach((el) => {
      el.hidden = el.dataset.tabContent !== target;
    });

    // Optional: keep buttons visually in sync without "active"
    container.querySelectorAll("[data-tab]").forEach((btn) => {
      const isActive = btn.dataset.tab === target;
      btn.setAttribute("aria-selected", isActive);
      btn.tabIndex = isActive ? 0 : -1;
    });
  }
}

window.customElements.define("tab-display", TabDisplay);
