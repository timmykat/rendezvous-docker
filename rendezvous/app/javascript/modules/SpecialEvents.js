export class SpecialEvents extends HTMLElement {
  connectedCallback() {
    this.init();
  }

  disconnectedCallback() {
    this.removeEventListeners();
  }

  init() {
    this.total = this.querySelector("input.display-total");
    this.attendeeFeeInput = this.querySelector("input#attendee-fee-reference");
    if (!this.attendeeFeeInput) {
      console.log("No registration fee input!");
    }
    this.attendeeFee = parseFloat(this.attendeeFeeInput.value);
    this.cruiseSelect = this.querySelector("select.lake-cruise");
    this.cruiseFeeInput = this.querySelector("input.lake-cruise-fee");
    const card = document.querySelector('.card[data-event="cruise"]');
    this.price = card?.dataset.price;
    this.setEventListeners();
  }

  setEventListeners() {
    this.cruiseSelect.addEventListener("change", this.dispatchRecalculate);
    document.addEventListener("RECALCULATE", this.updateFormValues);
  }

  removeEventListeners() {
    this.cruiseSelect.removeEventListener("change", this.dispatchRecalculate);
    document.removeEventListener("RECALCULATE", this.updateFormValues);
  }

  dispatchRecalculate = (e) => {
    document.dispatchEvent(
      new CustomEvent("RECALCULATE", { detail: { event: e } }),
    );
  };

  updateFormValues = (e) => {
    const evt = e?.detail?.event;
    if (!evt) return;
    const cruiseNumber = evt.target.value;
    const cruiseFee = parseFloat(cruiseNumber * this.price);
    if (cruiseFee > 0) {
      this.cruiseFeeInput.value = cruiseFee.toFixed(2);
      console.log("Should be set");
    } else {
      this.cruiseFeeInput.value = "";
    }
    this.total.value = (this.attendeeFee + cruiseFee).toFixed(2);
  };

  getCsrfHeaders = () => {
    let token = document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute("content");
    return {
      "Content-Type": "application/json",
      "X-CSRF-Token": token,
    };
  };
}
window.customElements.define("special-events", SpecialEvents);
