import "@oddcamp/cocoon-vanilla-js";

export class AttendanceManager extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    this.setupEventListeners();
    this.initializeFirstAttendee();
    this.initializeTypeFees();
    this.getAttendeeTotals();
  }

  setupEventListeners = () => {
    // 1. Radio button changes (Event Delegation)
    this.addEventListener("change", (e) => {
      const radio = e.target.closest('input[type="radio"]');
      if (!radio) return;

      this.setAttendeeFee(e.target.value, e.target);
      this.getAttendeeTotals();
    });

    this.addEventListener("cocoon:after-insert", (e) => {
      setTimeout(() => {
        this.updateHeaders();
        // In vanilla JS, the inserted item is in e.detail[0] or e.detail.node
        let insertedNode;
        if (e.detail.node instanceof Node) {
          insertedNode = e.detail.node;
        } else if (typeof e.detail.node === "string") {
          const tempDiv = document.createElement("div");
          tempDiv.innerHTML = e.detail.node.trim();
          insertedNode = tempDiv.firstChild;
        }

        const checkedRadio = insertedNode?.querySelector(
          'input[type="radio"]:checked',
        );

        if (checkedRadio) {
          this.setAttendeeFee(checkedRadio.value, checkedRadio);
        }

        this.getAttendeeTotals();
      }, 100);
    });

    this.addEventListener("cocoon:after-remove", () => {
      this.updateHeaders();
      this.getAttendeeTotals();
    });
  };

  updateHeaders = () => {
    Array.from(this.querySelectorAll(".attendee-type")).forEach((el, index) => {
      if (index !== 0) el.innerHTML = "Guest";
    });
  };

  setAttendeeFee = (type, target) => {
    const card = target.closest(".card");
    if (!card) return;

    const fees =
      window.appData && window.appData.fees ? window.appData.fees : {};
    const fee = fees[type] || 0;

    card.dataset.fee = fee;
  };

  getAttendeeTotals = () => {
    // 1. Identify valid, visible nested fields once
    const visibleNestedFields = Array.from(
      this.querySelectorAll('.nested-fields:not([style*="display: none"])'),
    );

    // 2. Pass those fields to updateCount for each type
    this.updateCount("adult", visibleNestedFields);
    this.updateCount("youth", visibleNestedFields);
    this.updateCount("child", visibleNestedFields);

    // 3. Calculate financial total using the same array
    let attendeeFeeTotal = 0;
    visibleNestedFields.forEach((field) => {
      const card = field.querySelector(".card.attendee");
      if (card) {
        console.log("Category fee", card.dataset.fee);
        attendeeFeeTotal += parseFloat(card.dataset.fee) || 0;
      }
    });

    // We let the before_save method save the total amount
    const totalDisplayInput = this.querySelector(".attendee-total");
    console.log("New fee total", attendeeFeeTotal.toFixed(2));
    if (totalDisplayInput)
      totalDisplayInput.value = attendeeFeeTotal.toFixed(2);
  };

  updateCount = (type, visibleNestedFields) => {
    let count = 0;

    visibleNestedFields.forEach((fieldSet) => {
      const checked = fieldSet.querySelector('input[type="radio"]:checked');
      if (checked && checked.value === type) {
        console.log("Adding", type);
        count++;
      }
    });

    let pluralType = type === "child" ? "children" : `${type}s`;
    const input = document.getElementById(
      `event_registration_number_of_${pluralType}`,
    );

    if (input) input.value = count || 0;

    return count;
  };

  initializeTypeFees = () => {
    const visibleNestedFields = Array.from(
      this.querySelectorAll('.nested-fields:not([style*="display: none"])'),
    );

    visibleNestedFields.forEach((attendee) => {
      const ageSelection = attendee.querySelector(
        'input[type="radio"]:checked',
      );
      const age = ageSelection.value;
      const card = ageSelection.closest(".card");
      card.dataset.fee = window.appData.fees[age];
    });
  };

  initializeFirstAttendee = () => {
    // Find the first nested-fields block
    const firstAttendee = this.querySelector("#attendees .nested-fields");
    if (!firstAttendee) return;

    // Remove delete button for the primary registrant
    const removeBtn = firstAttendee.querySelector(".remove_association_action");
    if (removeBtn) removeBtn.remove();

    // Lock the first attendee to "Adult" (disable youth/child options)
    const restrictedRadios = firstAttendee.querySelectorAll(
      'input[value="youth"], input[value="child"]',
    );
    restrictedRadios.forEach((radio) => {
      radio.disabled = true;
      const wrapper = radio.closest(".form-check") || radio.parentElement;
      if (wrapper) wrapper.style.display = "none";
    });

    const nameInput = firstAttendee.querySelector(
      ".event_registration_attendees_name input",
    );
    if (nameInput && !nameInput.value) {
      nameInput.setAttribute("placeholder", "Your name *");

      const firstName =
        document.getElementById("event_registration_user_attributes_first_name")
          ?.value || "";
      const lastName =
        document.getElementById("event_registration_user_attributes_last_name")
          ?.value || "";
      if (firstName || lastName) {
        nameInput.value = `${firstName} ${lastName}`.trim();
      }
    }

    // Ensure the first attendee has a fee set (defaulting to adult)
    const activeRadio =
      firstAttendee.querySelector('input[type="radio"]:checked') ||
      firstAttendee.querySelector('input[value="adult"]');
    if (activeRadio) {
      this.setAttendeeFee(activeRadio.value, activeRadio);
    }
    this.updateHeaders();
  };
}

customElements.define("attendance-manager", AttendanceManager);
