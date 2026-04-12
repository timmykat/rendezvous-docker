export class SpecialEvents extends HTMLElement {
  connectedCallback() {
    this.init();
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
    console.log(this.cruiseFeeInput);
    const card = document.querySelector('.card[data-event="cruise"]');
    this.price = card?.dataset.price;
    this.setEventListeners();
  }

  setEventListeners() {
    this.cruiseSelect.addEventListener("change", (e) => {
      console.log(e, this.price);
      this.updateFormValues(e.target.value);
    });
  }

  updateFormValues(cruiseNumber) {
    const cruiseFee = parseFloat(cruiseNumber * this.price);
    console.log(cruiseFee);
    if (cruiseFee > 0) {
      this.cruiseFeeInput.value = cruiseFee.toFixed(2);
      console.log("Should be set");
    } else {
      this.cruiseFeeInput.value = "";
    }
    this.total.value = (this.attendeeFee + cruiseFee).toFixed(2);
  }

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
