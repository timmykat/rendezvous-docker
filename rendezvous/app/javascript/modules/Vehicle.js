const OTHER_FRENCH = ['Panhard', 'Peugeot', 'Renault']

export class Vehicle extends HTMLElement {
  connectedCallback () {
    console.log('Vehicle connected')
    this.init()
  }

  init () {
    this.marqueSelect = this.querySelector('select.marque')
    this.modelSelect = this.querySelector('select.model')
    this.otherMarqueText = this.querySelector('input.marque.text')
    this.otherModelText = this.querySelector('input.model.text')
    this.marqueDataField = this.querySelector('input.marque.data')
    this.modelDataField = this.querySelector('input.model.data')
    this.setEventListeners()
  }

  setEventListeners () {
    this.marqueSelect.addEventListener('change', (e) => {
      this.setInputFieldStates()
      this.updateFormValues()
    })
    this.modelSelect.addEventListener('change', (e) => {
      this.setInputFieldStates()
      this.updateFormValues()
    })
    this.otherMarqueText.addEventListener('blur', (e) => {
      this.setInputFieldStates()
      this.updateFormValues()
    })
    this.otherModelText.addEventListener('blur', (e) => {
      this.setInputFieldStates()
      this.updateFormValues()
    })
    document.addEventListener('DOMContentLoaded', () => {
      this.setInitialControls()
    })
  }

  setInitialControls () {
    const marque = this.marqueDataField?.value
    const model = this.modelDataField?.value
    console.log("Marque: ", marque)
    console.log("Model: ", model)
    if (!marque) {
      console.log('No initial data')
      return
    }

    if (marque === 'Citroen') {
      this.marqueSelect.value = marque
      this.modelSelect.value = model
    } else if (OTHER_FRENCH.includes(marque)) {
      this.marqueSelect.value = marque
      this.otherModelText.value = model
    } else {
      this.marqueSelect.value = 'Non-French'
      this.otherMarqueText.value = marque
      this.otherModelText.value = model  
    }
    this.setInputFieldStates()
  }

  setInputFieldStates () {
    if (this.marqueSelect.value === 'Citroen') {
      this.enableField(this.marqueSelect);
      this.enableField(this.modelSelect);
      this.disableField(this.otherMarqueText);
      this.disableField(this.otherModelText);
    } else if (this.marqueSelect.value === "Non-French") {
      this.setFieldInactive(this.marqueSelect)
      this.disableField(this.modelSelect)
      this.enableField(this.otherMarqueText)
      this.enableField(this.otherModelText)
    } else {
      this.enableField(this.marqueSelect)
      this.enableField(this.otherModelText)
      this.disableField(this.otherMarqueText)
      this.disableField(this.modelSelect)
    }
  }

  setFieldActive (field) {
    field.setAttribute('data-active', '')
  }

  setFieldInactive (field) {
    field.removeAttribute('data-active')
  }

  disableField (field) {
    field.value = null
    field.disabled = 'disabled'
    this.setFieldInactive(field)
  } 

  enableField (field) {
    field.disabled = false
    this.setFieldActive(field)
  }

  updateFormValues = () => {
    this.marqueDataField.value = this.querySelector('.marque[data-active]').value
    this.modelDataField.value = this.querySelector('.model[data-active]').value
  }
}
