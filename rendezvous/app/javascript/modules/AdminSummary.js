import { debounce } from "throttle-debounce";

export class AdminSummary extends HTMLElement {
  constructor() {
    super();
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
      field.addEventListener("change", this.dispatchRecalculate);
    });

    this.currencyFields.forEach((field) => {
      field.addEventListener("blur", this.formatCurrency);
    });
  };

  dispatchRecalculate = () => {
    document.dispatchEvent(new Event("RECALCULATE"));
  };

  removeEventListeners = () => {
    document.removeEventListener("RECALCULATE", this.processFieldsDebounced);
    this.recalculateTriggers.forEach((field) => {
      field.removeEventListener("input", this.dispatchRecalculate);
      field.removeEventListener("change", this.dispatchRecalculate);
    });

    this.currencyFields.forEach((field) => {
      field.removeEventListener("blur", this.formatCurrency);
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

    this.setPaymentStatus(balance);
  };

  formatCurrency = () => {
    // Format output fields
    if (this.balanceField) {
      const balance = this.balanceField.value;
      this.balanceField.value = parseFloat(balance).toFixed(2);
    }
    if (this.donationField) {
      const donation = this.donationField.value;
      this.donationField.value = parseFloat(donation).toFixed(2);
    }
    if (this.paidAmountField) {
      const paidAmount = this.paidAmountField.value;
      this.paidAmountField.value = parseFloat(paidAmount).toFixed(2);
    }
    if (this.totalField) {
      const total = this.totalField.value;
      this.totalField.value = parseFloat(total).toFixed(2);
    }
  };

  setPaymentStatus = (total, balance) => {
    if (balance == 0.0) return "paid";
    if (Math.abs(total - balance) < 0.01) return "payment due";
    if (balance > 0.0) return "outstanding balance";
    if (balance < 0.0) return "refund owed";
  };
}

customElements.define("admin-summary", AdminSummary);
