import { debounce } from "throttle-debounce";

const OTHER_FRENCH = ["Panhard", "Peugeot", "Renault"];

export class Vehicle extends HTMLElement {
  connectedCallback() {
    requestAnimationFrame(() => {
      this.init();
    });
  }

  disconnectedCallback() {
    this.removeEventListeners();
  }

  init() {
    this.label = this.querySelector(".vehicle-label");
    console.log(this.label);
    this.yearSelect = this.querySelector("select.year-selector");
    this.marqueSelect = this.querySelector("select.marque");
    this.modelSelect = this.querySelector("select.model");
    this.otherMarqueText = this.querySelector("input.marque.text");
    this.otherModelText = this.querySelector("input.model.text");
    this.marqueDataField = this.querySelector("input.marque.data");
    this.modelDataField = this.querySelector("input.model.data");
    this.qrIdField = this.querySelector("[data-qr-id-field]");
    this.codeFieldBadge = this.querySelector(".badge");

    if (!this.marqueSelect || !this.modelSelect) {
      console.warn(
        "RendezvousVehicle: Required select fields not found in DOM.",
      );
      return;
    }
    this.setEventListeners();
    this.setInitialControls();
    this.updateLabel();
  }

  setEventListeners() {
    this.marqueSelect.addEventListener("change", this.handleFieldChange);
    this.modelSelect.addEventListener("change", this.handleFieldChange);
    this.otherMarqueText.addEventListener(
      "keydown",
      this.handleFieldChangeDebounce,
    );
    this.otherModelText.addEventListener(
      "keydown",
      this.handleFieldChangeDebounce,
    );
    this.yearSelect.addEventListener("change", this.updateLabel);
  }

  removeEventListeners() {
    this.marqueSelect.removeEventListener("change", this.handleFieldChange);
    this.modelSelect.removeEventListener("change", this.handleFieldChange);
    this.otherMarqueText.removeEventListener(
      "keydown",
      this.handleFieldChangeDebounce,
    );
    this.otherModelText.removeEventListener(
      "keydown",
      this.handleFieldChangeDebounce,
    );
    this.yearSelect.removeEventListener("change", this.updateLabel);
  }

  handleFieldChange = () => {
    this.setInputFieldStates();
    this.updateFormValues();
    this.updateLabel();
  };

  handleFieldChangeDebounce = () => {
    debounce(500, this.handleFieldChange);
  };

  setInitialControls() {
    const marque = this.marqueDataField?.value;
    const model = this.modelDataField?.value;
    if (!marque) {
      return;
    }

    if (marque === "Citroen") {
      this.marqueSelect.value = marque;
      this.modelSelect.value = model;
    } else if (OTHER_FRENCH.includes(marque)) {
      this.marqueSelect.value = marque;
      this.otherModelText.value = model;
    } else {
      this.marqueSelect.value = "Non-French";
      this.otherMarqueText.value = marque;
      this.otherModelText.value = model;
    }
    this.setInputFieldStates();
  }

  setInputFieldStates() {
    if (this.marqueSelect.value === "Citroen") {
      this.enableField(this.marqueSelect);
      this.enableField(this.modelSelect);
      this.disableField(this.otherMarqueText);
      this.disableField(this.otherModelText);
    } else if (this.marqueSelect.value === "Non-French") {
      this.setFieldInactive(this.marqueSelect);
      this.disableField(this.modelSelect);
      this.enableField(this.otherMarqueText);
      this.enableField(this.otherModelText);
    } else {
      this.enableField(this.marqueSelect);
      this.enableField(this.otherModelText);
      this.disableField(this.otherMarqueText);
      this.disableField(this.modelSelect);
    }
  }

  setFieldActive(field) {
    field.setAttribute("data-active", "");
  }

  setFieldInactive(field) {
    field.removeAttribute("data-active");
  }

  disableField(field) {
    field.value = null;
    field.disabled = "disabled";
    this.setFieldInactive(field);
  }

  enableField(field) {
    field.disabled = false;
    this.setFieldActive(field);
  }

  updateFormValues = () => {
    this.marqueDataField.value = this.querySelector(
      ".marque[data-active]",
    ).value;
    this.modelDataField.value = this.querySelector(".model[data-active]").value;
  };

  updateLabel = () => {
    const year = this.yearSelect.value;
    const marque = this.marqueDataField.value;
    const model = this.modelDataField.value;
    const fullName = `${year} ${marque} ${model}`;
    console.log("Updating label", fullName);
    this.label.textContent = fullName;
  };
}
window.customElements.define("rendezvous-vehicle", Vehicle);
