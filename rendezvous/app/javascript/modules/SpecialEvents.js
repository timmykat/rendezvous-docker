import { debounce } from 'throttle-debounce'

export class SpecialEvents extends HTMLElement {
  connectedCallback () {
    requestAnimationFrame(() => {
      this.init()
    })
  }

  init () {
    this.incomingFee = parseFloat(this.querySelector('input[name="incoming_registration_fee"]').value)
    this.cruiseSelect = this.querySelector('select.lake-cruise')
    this.cruiseFee = this.querySelector('input.lake-cruise-fee')
    this.registrationFee = this.querySelector('input.registration-fee')
    const card = document.querySelector('.card[data-event="cruise"]')
    this.price = card?.dataset.price;
    this.setEventListeners()
  }

  setEventListeners () {
    this.cruiseSelect.addEventListener('change', (e) => {
      console.log(e, this.price)
      this.updateFormValues(e.target.value)
    })
  }

  updateFormValues (cruiseNumber) {
    const cruiseFee = parseFloat(cruiseNumber * this.price)
    if (cruiseFee > 0) {
      this.cruiseFee.value = cruiseFee.toFixed(2)
    } else {
      this.cruiseFee.value = ''
    }
    this.registrationFee.value = (this.incomingFee + cruiseFee).toFixed(2)
  }

  getCsrfHeaders = () => {
    let token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    return {
      "Content-Type": "application/json",
      "X-CSRF-Token": token
    };
  };
}
window.customElements.define('special-events', SpecialEvents);
