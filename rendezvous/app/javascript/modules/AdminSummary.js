import { debounce } from "throttle-debounce";

export class AdminSummary extends HTMLElement {
  constructor() {
    super();
    this.processFields = this.processFields.bind(this);
    this.processFieldsDebounced = debounce(500, this.processFields);
  }

  connectedCallback() {
    this.sourceFields = this.querySelectorAll("[data-summary-source]");
    this.totalField = this.querySelector("[data-target-total]");
    this.balanceField = this.querySelector("[data-target-balance]");
    this.paymentStatusSelect = this.querySelector(
      "[data-target-payment-status]",
    );
    this.donationField = this.querySelector("[data-donation]");
    this.paidAmountField = this.querySelector("[data-paid-amount]");
    this.currencyFields = this.querySelectorAll(".fixed-2");
    this.recalculateTriggers = this.querySelectorAll(
      "[data-recalculate-trigger]",
    );

    this.setupEventListeners();
    this.processFields(); // Initial calculation
  }

  disconnectedCallback() {
    this.removeEventListeners();
  }

  setupEventListeners = () => {
    document.addEventListener("RECALCULATE", this.processFieldsDebounced);
    this.recalculateTriggers.forEach((field) => {
      field.addEventListener("input", this.dispatchRecalculate);
    });
  };

  dispatchRecalculate = () => {
    document.dispatchEvent(new Event("RECALCULATE"));
  };

  removeEventListeners = () => {
    document.removeEventListener("RECALCULATE", this.processFieldsDebounced);
    this.recalculateTriggers.forEach((field) => {
      field.removeEventListener("input", this.dispatchRecalculate);
    });
  };

  processFields = () => {
    // Compute total from summary source fields
    const total = Array.from(this.sourceFields).reduce((sum, f) => {
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

    this.setPaymentStatus(balance);

    // Format currency fields
    this.currencyFields.forEach((field) => {
      if (!field) return;
      let value = parseFloat(field.value);
      if (!isNaN(value)) {
        field.value = value.toFixed(2);
      }
    });
  };

  setPaymentStatus = (total, balance) => {
    if (balance == 0.0) return "paid";
    if (Math.abs(total - balance) < 0.01) return "payment due";
    if (balance > 0.0) return "outstanding balance";
    if (balance < 0.0) return "refund owed";
  };
}

customElements.define("admin-summary", AdminSummary);
