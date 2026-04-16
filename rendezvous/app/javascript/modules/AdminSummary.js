import { debounce } from "throttle-debounce";

export class AdminSummary extends HTMLElement {
  constructor() {
    super();
    this.processFields = this.processFields.bind(this);
    this.processFieldsDebounced = debounce(500, this.processFields);
  }

  connectedCallback() {
    this.watchFields = this.querySelectorAll("[data-summary-source]");
    this.totalField = this.querySelector("[data-target-total]");
    this.balanceField = this.querySelector("[data-target-balance]");
    this.paidAmountField = this.querySelector("[data-paid-amount]");
    this.currencyFields = this.querySelectorAll(".fixed-2");

    this.setupEventListeners();
    this.processFields(); // Initial calculation
  }

  disconnectedCallback() {
    this.removeEventListeners();
  }

  setupEventListeners = () => {
    this.watchFields.forEach((field) => {
      field.addEventListener("input", this.processFieldsDebounced);
      field.addEventListener("change", this.processFieldsDebounced);
    });
    if (this.paidAmountField) {
      this.paidAmountField.addEventListener(
        "input",
        this.processFieldsDebounced,
      );
    }
  };

  removeEventListeners = () => {
    this.watchFields.forEach((field) => {
      field.removeEventListener("input", this.processFieldsDebounced);
      field.removeEventListener("change", this.processFieldsDebounced);
    });
    if (this.paidAmountField) {
      this.paidAmountField.removeEventListener(
        "input",
        this.processFieldsDebounced,
      );
    }
  };

  processFields = () => {
    // Compute total from summary source fields
    const total = Array.from(this.watchFields).reduce((sum, f) => {
      // only sum if value can be parsed
      const v = parseFloat(f.value);
      return sum + (isNaN(v) ? 0 : v);
    }, 0);

    // Get paid amount
    const paid =
      this.paidAmountField && !isNaN(parseFloat(this.paidAmountField.value))
        ? parseFloat(this.paidAmountField.value)
        : 0;

    // Calculate balance
    const balance = total - paid;

    // Update output fields
    if (this.totalField) this.totalField.value = total.toFixed(2);
    if (this.balanceField) this.balanceField.value = balance.toFixed(2);

    // Format currency fields
    this.currencyFields.forEach((field) => {
      if (!field) return;
      let value = parseFloat(field.value);
      if (!isNaN(value)) {
        field.value = value.toFixed(2);
      }
    });
  };
}

customElements.define("admin-summary", AdminSummary);
