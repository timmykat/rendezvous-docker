export class TabDisplay extends HTMLElement {
  connectedCallback() {
    this.addEventListener("click", this.tabHandler);
    this.setupTabs();
    this.defaultTab = this.querySelector("li").getAttribute("id");
    document.addEventListener("turbo:load", () => this.setByHash());
  }

  disconnectedCallback() {
    this.removeEventListener("click", this.tabHandler);
    document.removeEventListener("turbo:load", () => this.setByHash());
  }

  setupTabs() {
    const contents = this.querySelectorAll(".tab-content");

    // Set summary tab to visible
    contents.forEach((panel, index) => {
      panel.hidden = index !== 0;
    });
  }

  setByHash = () => {
    console.log("load event received");
    const hash = window.location.hash;
    if (!hash) {
      this.ensureHash(this.defaultTab);
      return;
    }

    const li = this.querySelector("li" + hash);
    if (!li) return;

    const container = li.closest("[data-tabbed]");
    const btn = li.querySelector("button");
    console.log(container, btn);
    this.activateTab(container, btn.dataset.tab);
  };

  ensureHash = (tab) => {
    window.location.hash = "#" + tab;
  };

  tabHandler = (e) => {
    const btn = e.target.closest("[data-tab]");
    if (!btn) return;

    const container = btn.closest("[data-tabbed]");
    const tab = btn.dataset.tab;
    this.activateTab(container, tab);
    this.ensureHash(tab);
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
      const li = btn.closest("li");
      if (isActive) {
        li.classList.add("active");
      } else {
        li.classList.remove("active");
      }
    });
  }
}

window.customElements.define("tab-display", TabDisplay);
