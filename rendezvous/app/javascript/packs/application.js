import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"

import { debounce } from 'throttle-debounce';
import 'jquery/dist/jquery.min'; 
import 'html5shiv/dist/html5shiv.min';
import 'popper.js';
import 'bootstrap/dist/js/bootstrap';
import 'jquery-ui/ui/widgets/sortable';
import 'jquery-ui/ui/widgets/tabs';
import 'magnific-popup/dist/jquery.magnific-popup.min';
import 'lazyload/lazyload.min';
import 'cocoon-js';
import { initCustom } from '../modules/custom'
import '../modules/main_pages';
import { RecaptchaHandler } from '../modules/recaptcha';
window.RecaptchaHandler = RecaptchaHandler
import '../modules/user'; 
import '../modules/vehicles'; 

Rails.start()
Turbolinks.start()
ActiveStorage.start()

