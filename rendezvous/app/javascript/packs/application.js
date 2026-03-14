import $ from 'jquery'
window.$ = $
window.jQuery = $

import "@hotwired/turbo-rails"
import '@hotwired/stimulus'
import 'throttle-debounce'

// My web components
import '../modules/AttendanceManager'
import '../modules/PaymentManager'
import '../modules/SpecialEvents'
import '../modules/Vehicle'

import 'html5shiv/dist/html5shiv.min'
import 'popper.js'
import 'bootstrap/dist/js/bootstrap'
import 'jquery-ui/ui/widgets/sortable'
import 'jquery-ui/ui/widgets/tabs'
import 'magnific-popup/dist/jquery.magnific-popup.min'
import 'lazyload/lazyload.min'
import "html5-qrcode"
import '@oddcamp/cocoon-vanilla-js'

import { RecaptchaHandler } from '../modules/recaptcha'
window.RecaptchaHandler = RecaptchaHandler

import { initCustom, setButtonSpinner } from '../modules/custom'
document.addEventListener('DOMContentLoaded', () => initCustom())
document.addEventListener('turbo:load', () => initCustom())

window.setButtonSpinner = setButtonSpinner

import '../modules/jquery_tabs'
import '../modules/main_pages'
// import '../modules/registration'
import '../modules/user' 


import { Cookies } from "js-cookie"
window.Cookies = Cookies

// import { registerCocoonHandlers } from '../modules/cocoon_vanilla_js'

// document.addEventListener('turbo:load', () => {
//   // Check if it's already defined to avoid double-binding if your script re-runs
//   if (typeof registerCocoonHandlers === 'function') {
//     registerCocoonHandlers()
//   }
// })

Turbo.start()


