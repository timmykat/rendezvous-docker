import "@hotwired/turbo-rails";

import "@hotwired/stimulus";
import "throttle-debounce";

import "html5-qrcode";

import "bootstrap/dist/js/bootstrap";

import { initCustom } from "./modules/custom";

import "./modules/TabDisplay";
import "./modules/VotingApp";

import "./modules/main_pages";

document.addEventListener("turbo:load", () => initCustom());
Turbo.start();
