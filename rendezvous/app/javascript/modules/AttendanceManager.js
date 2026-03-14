import '@oddcamp/cocoon-vanilla-js';

export class AttendanceManager extends HTMLElement {
  constructor() {
    super();
    this.getAttendeeTotals = this.getAttendeeTotals.bind(this);
    this.setTotal = this.setTotal.bind(this);
  }

  connectedCallback() {
    this.setupEventListeners();
    this.initializeFirstAttendee();
    this.getAttendeeTotals();
  }

  setupEventListeners() {
    // 1. Radio button changes (Event Delegation)
    this.addEventListener('change', (e) => {
      if (e.target.matches('#attendees input[type="radio"]')) {
        this.setAttendeeFee(e.target.value, e.target);
        this.getAttendeeTotals();
      }
    });

    // 2. Vanilla Cocoon Hooks
    // Note: cocoon-vanilla-js dispatches native events: 'cocoon:after-insert' and 'cocoon:after-remove'
    const attendeeContainer = this.querySelector('#attendees');
    if (attendeeContainer) {
      
      attendeeContainer.addEventListener('cocoon:after-insert', (e) => {
        // In vanilla JS, the inserted item is in e.detail[0] or e.detail.node
        let insertedNode
        if (e.detail.node instanceof Node) {
          insertedNode = e.detail.node;
        } else if (typeof e.detail.node === 'string') {
          const tempDiv = document.createElement('div');
          tempDiv.innerHTML = e.detail.node.trim();
          insertedNode = tempDiv.firstChild;
        }
        
        const checkedRadio = insertedNode?.querySelector('input[type="radio"]:checked');
        
        if (checkedRadio) {
          this.setAttendeeFee(checkedRadio.value, checkedRadio);
        }
        this.getAttendeeTotals();
      });

      attendeeContainer.addEventListener('cocoon:after-remove', () => {
        this.getAttendeeTotals();
      });
    }
  }

  setAttendeeFee(type, target) {
    const card = target.closest('.card');
    if (!card) return;

    const fees = (window.appData && window.appData.fees) ? window.appData.fees : {};
    const fee = fees[type] || 0;
    
    card.dataset.fee = fee;
  }

  getAttendeeTotals() {
    let attendeeTotal = 0;
    // We filter for cards that are NOT hidden (cocoon hides removed items if they are persisted)
    const visibleCards = this.querySelectorAll('.card.attendee:not([style*="display: none"])');

    visibleCards.forEach(card => {
      attendeeTotal += parseFloat(card.dataset.fee) || 0;
    });

    const feeInput = document.getElementById('event_registration_registration_fee');
    if (feeInput) feeInput.value = attendeeTotal.toFixed(2);

    this.updateCount('adult');
    this.updateCount('youth');
    this.updateCount('child');

    this.setTotal();
  }

  updateCount(type) {
    // Ensure we only count checked radios in visible attendee rows
    const count = Array.from(this.querySelectorAll(`#attendees input[value="${type}"]:checked`))
      .filter(el => el.closest('.nested-fields').style.display !== 'none').length;

    const input = document.getElementById(`event_registration_number_of_${type}s`);
    if (input) input.value = count;
  }

  async setTotal() {
    if (document.documentElement.hasAttribute("data-turbo-visit_control")) return;

    const regId = this.dataset.registrationId;
    if (!regId || !window.appData) return;

    const feeInput = document.getElementById('event_registration_registration_fee');
    const donationInput = document.querySelector('input[name="event_registration[donation]"]');
    
    const regFee = parseFloat(feeInput?.value) || parseFloat(window.appData.event_registration_fee) || 0;
    const donation = parseFloat(donationInput?.value) || 0;
    const total = regFee + donation;

    const totalInput = document.getElementById('event_registration_total');
    if (totalInput) totalInput.value = total.toFixed(2);

    if (total <= 0) return;

    try {
      const response = await fetch('/event/ajax/update_fees', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]')?.content,
          'Accept': 'application/json'
        },
        body: JSON.stringify({ id: regId, donation, total })
      });
      if (!response.ok) throw new Error('Network response was not ok');
      const data = await response.json();
      console.log('Update successful:', data);
    } catch (error) {
      console.error('Error updating fees:', error);
    }
  }

  initializeFirstAttendee() {
    // Find the first nested-fields block
    const firstAttendee = this.querySelector('#attendees .nested-fields');
    if (!firstAttendee) return;

    // Remove delete button for the primary registrant
    const removeBtn = firstAttendee.querySelector('.remove_association_action');
    if (removeBtn) removeBtn.remove();
    
    // Lock the first attendee to "Adult" (disable youth/child options)
    const restrictedRadios = firstAttendee.querySelectorAll('input[value="youth"], input[value="child"]');
    restrictedRadios.forEach(radio => {
      radio.disabled = true;
      const wrapper = radio.closest('.form-check') || radio.parentElement;
      if (wrapper) wrapper.style.display = 'none';
    });

    const nameInput = firstAttendee.querySelector('.event_registration_attendees_name input');
    if (nameInput && !nameInput.value) {
      nameInput.setAttribute('placeholder', 'Your name *');
      
      const firstName = document.getElementById('event_registration_user_attributes_first_name')?.value || '';
      const lastName = document.getElementById('event_registration_user_attributes_last_name')?.value || '';
      if (firstName || lastName) {
        nameInput.value = `${firstName} ${lastName}`.trim();
      }
    }
    
    // Ensure the first attendee has a fee set (defaulting to adult)
    const activeRadio = firstAttendee.querySelector('input[type="radio"]:checked') || firstAttendee.querySelector('input[value="adult"]');
    if (activeRadio) {
      this.setAttendeeFee(activeRadio.value, activeRadio);
    }
  }
}

customElements.define('attendance-manager', AttendanceManager);