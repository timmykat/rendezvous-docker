import "./modules/jquery_setup";

import Cookies from "js-cookie";
window.Cookies = Cookies;

import "@hotwired/turbo-rails";

import "@hotwired/stimulus";
import "throttle-debounce";

import "bootstrap/dist/js/bootstrap";

import "html5-qrcode";
import "@oddcamp/cocoon-vanilla-js";

import "magnific-popup/dist/jquery.magnific-popup.min";

// My web components
import { initCustom, setButtonSpinner } from "./modules/custom";
import { RecaptchaHandler } from "./modules/recaptcha";
import "./modules/AttendanceManager";
import "./modules/PaymentManager";
import "./modules/SpecialEvents";
import "./modules/Vehicle";
import "./modules/main_pages";
import "./modules/user";

window.RecaptchaHandler = RecaptchaHandler;
window.setButtonSpinner = setButtonSpinner;

document.addEventListener("turbo:load", () => initCustom());
Turbo.start();
