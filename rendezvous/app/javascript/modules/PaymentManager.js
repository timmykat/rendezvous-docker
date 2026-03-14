export class PaymentManager extends HTMLElement {
  constructor() {
    super();
    // Bind methods to ensure 'this' refers to the class instance
    this.handleDonationChange = this.handleDonationChange.bind(this);
    this.handlePaymentChange = this.handlePaymentChange.bind(this);
    this.handleFormSubmit = this.handleFormSubmit.bind(this);
  }

  connectedCallback() {
    this.render();
    this.setupEventListeners();
    this.initializeState();
    this.setPaymentSpinner();
  }

  setupEventListeners() {
    // Donation calculation delegation
    this.addEventListener('click', (e) => this.delegateDonation(e));
    this.addEventListener('blur', (e) => this.delegateDonation(e), true);
    this.addEventListener('change', (e) => {
      if (e.target.classList.contains('total-calculation')) this.handleDonationChange(e.target);
      if (e.target.classList.contains('payment-method')) this.handlePaymentChange(e.target.value);
    });

    // Form submission safety
    const form = this.querySelector('form');
    if (form) form.addEventListener('submit', this.handleFormSubmit);
  }

  initializeState() {
    // Set initial payment method state based on checked radio
    const checkedPayment = this.querySelector('input.payment-method:checked');
    if (checkedPayment) {
      this.updatePaymentUI(checkedPayment.value);
    }
    
    // External function call from your original snippet
    if (typeof setPaymentSpinner === 'function') setPaymentSpinner();
  }

  delegateDonation(e) {
    if (e.target.classList.contains('total-calculation')) {
      this.handleDonationChange(e.target);
    }
  }

  handleDonationChange(target) {
    if (target.type === 'radio') {
      const val = target.value === 'other' ? 0 : parseFloat(target.value);
      const donationInput = document.getElementById('event_registration_donation');
      if (donationInput) {
        donationInput.value = val.toFixed(2);
      }
    }
    
    // Logic for setTotal (assumed global or accessible)
    if (typeof setTotal === 'function') setTotal();
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

  async updatePaymentUI(value) {
    const isOnline = value === 'credit card';
    const regId = this.dataset.registration_id;
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;

    // Toggle Elements
    this.toggleDisplay('#payment-online', isOnline);
    this.toggleDisplay('#payment-paid', isOnline);
    this.toggleDisplay('#payment-cash', !isOnline);

    // Ajax Replacement (Fetch API)
    try {
      const response = await fetch(`/event/ajax/update_paid_method?id=${regId}&paid_method=${value}`, {
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
    this.updatePaymentUI(value);
  }

  handleFormSubmit() {
    const inputs = this.querySelectorAll('input.calculated, input[type=email]');
    inputs.forEach(input => input.disabled = false);

    const loader = this.querySelector('.review-loader');
    if (loader) loader.style.display = 'block';
  }

  // Helper to replicate jQuery .toggle() / .show() / .hide()
  toggleDisplay(selector, show) {
    const el = this.querySelector(selector);
    if (el) el.style.display = show ? 'block' : 'none';
  }
}
window.customElements.define('payment-manager', PaymentManager);
