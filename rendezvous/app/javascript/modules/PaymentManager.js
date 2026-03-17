export class PaymentManager extends HTMLElement {
  constructor() {
    super();
    // Bind methods to ensure 'this' refers to the class instance
    this.updateFees = this.updateFees.bind(this)
    this.handleDonationChange = this.handleDonationChange.bind(this);
    this.handlePaymentChange = this.handlePaymentChange.bind(this);
    this.handleFormSubmit = this.handleFormSubmit.bind(this);
    this.setTotal = this.setTotal.bind(this)
  }

  connectedCallback() {
    this.setupEventListeners();
    this.setPaymentSpinner();
  }

  setupEventListeners() {
    this.addEventListener('keydown', (e) => {
      if (e.key === 'Enter') {
        const target = e.target;
        
        // 1. Check if it's the "Make Payment" link (link_to becomes an <a> tag)
        const isPaymentLink = target.tagName === 'A' && target.classList.contains('btn-square-pay');
        
        // 2. Check if it's the Submit button
        const isSubmitButton = target.type === 'submit';
  
        // If it's neither, kill the Enter key behavior
        if (!isPaymentLink && !isSubmitButton) {
          e.preventDefault();
        }
      }
    });

    this.addEventListener('change', (e) => {
      if (e.target.classList.contains('total-calculation')) this.handleDonationChange(e.target);
      if (e.target.classList.contains('payment-method')) this.handlePaymentChange(e.target.value);
    });

    // Handle manual typing in the donation field
    const donationInput = document.getElementById('event_registration_donation');
    if (donationInput) {
      donationInput.addEventListener('input', (e) => {
        this.setTotal(parseFloat(e.target.value) || 0);
      });
    }

    const form = this.querySelector('form');
    if (form) form.addEventListener('submit', this.handleFormSubmit);
  }

  delegateDonation(e) {
    if (e.target.classList.contains('total-calculation')) {
      this.handleDonationChange(e.target);
    }
  }

  handleDonationChange(target) {
    const donationInput = document.getElementById('event_registration_donation');
    if (!donationInput || target.type !== 'radio') return;

    // Fixed Capitalization: readOnly
    const isOther = target.value === 'other';
    donationInput.readOnly = !isOther;

    const val = isOther ? 0 : parseFloat(target.value);
    donationInput.value = val.toFixed(2);
    this.setTotal(val);
  }

  setTotal(donationValue) {
    const feeEl = document.getElementById('incoming_registration_fee');
    const totalInput = document.getElementById('event_registration_total');
    
    if (feeEl && totalInput) {
      const incomingFee = parseFloat(feeEl.value) || 0;
      const total = incomingFee + donationValue;
      totalInput.value = total.toFixed(2);
      this.updateFees({donation: donationValue, total: total});
    }
  }

  setPaymentSpinner() {
    this.addEventListener('click', (e) => {
      const btn = e.target.closest('.btn-square-pay');
      if (btn) {
        btn.textContent = "Connecting...";
        const spinner = document.createElement('div');
        spinner.className = 'spinner-grow text-primary';
        spinner.setAttribute('role', 'status');
        btn.after(spinner);
        btn.classList.remove('btn-square-pay');
      }
    });
  }

  async updateFees(params) {
    const regId = this.dataset.registrationId;
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;

    try {
      const response = await fetch(`/event/ajax/update_fees/${regId}`, {
        method: 'PATCH',
        headers: {
          'X-CSRF-Token': csrfToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({
          donation: params.donation,
          total: params.total
        })
      });
      if (!response.ok) throw new Error('Network response was not ok');
    } catch (error) {
      console.error('Update failed:', error);
    }
  }

  async updatePaymentMethod(value) {
    const isOnline = value === 'credit card';
    const regId = this.dataset.registration_id;
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;

    // Toggle Elements
    this.toggleDisplay('#payment-online', isOnline);
    this.toggleDisplay('#payment-cash', !isOnline);

    // Ajax Replacement (Fetch API)
    try {
      const response = await fetch(`/event/ajax/update_pad_method/${regId}?paid_method=${value}`, {
        method: 'GET',
        headers: {
          'X-CSRF-Token': csrfToken,
          'Content-Type': 'application/json'
        }
      });
      if (!response.ok) throw new Error('Network response was not ok');
    } catch (error) {
      console.error('Update failed:', error);
    }
  }

  handlePaymentChange(value) {
    this.updatePaymentMethod(value);
  }

  handleFormSubmit(e) {
    e.preventDefault(); // Now 'e' is defined!
    
    const loader = this.querySelector('.review-loader');
    if (loader) loader.style.display = 'block';

    e.target.submit(); // Form actually moves forward now
  }

  // Helper to replicate jQuery .toggle() / .show() / .hide()
  toggleDisplay(selector, show) {
    const el = this.querySelector(selector);
    if (el) el.style.display = show ? 'block' : 'none';
  }
}
window.customElements.define('payment-manager', PaymentManager);
