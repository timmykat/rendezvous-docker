export class RecaptchaHandler {
  constructor (formId, action) {
    this.formId = formId
    this.action = action
  }

  prepare () {
    this.siteKey = document.querySelector('body').dataset.siteKey
    this.formSubmit = document.querySelector(`#${this.formId} input[type="submit"], #${this.formId} button[type="submit"]`)
    if (!this.formSubmit) {
      console.error('Submit button not found for', this.formId);
      return;
    }

    this.formInput = document.createElement('input')
    this.formInput.name = 'recaptcha_token'
    this.formInput.type = 'hidden'
    this.formInput.classList.add('recaptcha')
    this.formInput.value = ''
    this.formSubmit.parentNode.insertBefore(this.formInput, this.formSubmit)
  }

  execute () {
    const script = document.createElement('script')
    script.src = `https://www.google.com/recaptcha/api.js?render=${encodeURIComponent(this.siteKey)}`
    script.async = true
    script.defer = true
    script.onload = this.processRecaptcha
    document.head.appendChild(script)
  }

  processRecaptcha = () => {
    window.grecaptcha.ready(() => {
      grecaptcha.execute(this.siteKey, { action: this.action })
        .then(token => {
          this.formInput.value = token
        })
    })
  }
}
