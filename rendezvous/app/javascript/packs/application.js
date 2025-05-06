import $ from 'jquery';
 

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import { debounce } from 'throttle-debounce';
import 'html5shiv/dist/html5shiv.min';
import 'popper.js';
import 'bootstrap/dist/js/bootstrap';
import 'jquery-ui/ui/widgets/sortable';
import 'jquery-ui/ui/widgets/tabs';
import 'magnific-popup/dist/jquery.magnific-popup.min';
import 'lazyload/lazyload.min';

import { initCustom, setButtonSpinner } from '../modules/custom'
document.addEventListener('DOMContentLoaded', () => initCustom())
window.setButtonSpinner = setButtonSpinner

import '../modules/main_pages';
import { RecaptchaHandler } from '../modules/recaptcha';
window.RecaptchaHandler = RecaptchaHandler
import '../modules/user'; 
import '../modules/vehicles'; 
import { registerCocoonHandlers } from '../modules/cocoon_vanilla_js'
registerCocoonHandlers()

Rails.start()
Turbolinks.start()


