import { debounce } from 'throttle-debounce';
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
    this.codeField = this.querySelector('[data-code-autocomplete]')
    this.qrIdField = this.querySelector('[data-qr-id-field]')
    this.codeFieldBadge = this.querySelector('.badge')
    this.codeAutocompleteDebounce = debounce(500, this.codeAutocomplete.bind(this));
    this.setEventListeners()
    this.setInitialControls()
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
    console.log('Setting debounced autocomplete')
    this.codeField.addEventListener('keyup', this.codeAutocompleteDebounce)
  }

  codeAutocomplete (e) {
    console.log('Fetching')
    const field = e.target
    const code = field.value.toUpperCase()
    console.log(field, code)
    if (code === null || code === '' || !/^[1-9a-z]{4,4}$/i.test(code)) {
      return
    }

    fetch(`/ajax/code/search?code=${code}`, { headers: this.getCsrfHeaders() })
    .then(response => response.json())
    .then(data => {
      console.log('Fetch data:', data)
      if (data.status === 'OK') {
        this.qrIdField.value = data.id
        this.codeFieldBadge.classList.remove('hide')
      } else {
        this.codeFieldBadge.classList.add('hide')
      }
    })
  }

  setInitialControls () {
    const marque = this.marqueDataField?.value
    const model = this.modelDataField?.value
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

  getCsrfHeaders = () => {
    let token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    return {
      "Content-Type": "application/json",
      "X-CSRF-Token": token
    };
  };
}
