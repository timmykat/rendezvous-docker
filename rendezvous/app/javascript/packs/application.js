import $ from 'jquery';
window.$ = $;
window.jQuery = $;

import "@hotwired/turbo-rails"
import { Application } from '@hotwired/stimulus'
import { debounce } from 'throttle-debounce';
import 'html5shiv/dist/html5shiv.min';
import 'popper.js';
import 'bootstrap/dist/js/bootstrap';
import 'jquery-ui/ui/widgets/sortable';
import 'jquery-ui/ui/widgets/tabs';
import 'magnific-popup/dist/jquery.magnific-popup.min';
import 'lazyload/lazyload.min';
import "html5-qrcode"

import { RecaptchaHandler } from '../modules/recaptcha';
window.RecaptchaHandler = RecaptchaHandler

import { initCustom, setButtonSpinner } from '../modules/custom'
document.addEventListener('DOMContentLoaded', () => initCustom())
document.addEventListener('turbo:load', () => initCustom())

window.setButtonSpinner = setButtonSpinner

import '../modules/jquery_tabs'
import '../modules/main_pages';
import '../modules/registration';
import '../modules/user'; 
import '../modules/vehicles';
import "../controllers"

import { Cookies } from "js-cookie"
window.Cookies = Cookies

import { registerCocoonHandlers } from '../modules/cocoon_vanilla_js'
window.registerCocoonHandlers = registerCocoonHandlers
registerCocoonHandlers()

document.addEventListener('turbo:load', () => {
  registerCocoonHandlers()
})

Turbo.start()


