import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo"
import { debounce } from "throttle-debounce"
import { Html5Qrcode, Html5QrcodeScannerState } from "html5-qrcode"
import Cookies from "js-cookie"

const CODE_LENGTH = 6

export default class extends Controller {
  static targets = [
    "cancel",
    "errorInfo",
    "errorWrapper",
    "reader", 
    "selection",
    "selectionInfo", 
    "selectionWrapper", 
    "voteActionContainer",
    "votingForm",
    "warningInfo",
    "warningWrapper"
  ]

  connect () {
    this.scanner = new Html5Qrcode(this.readerTarget.id)
    this.handleInputPreference()

    this.debouncedGetVehicle = debounce(500, () => {
      const code = this.selectionTarget.value;
      if (code.length === CODE_LENGTH) {
        const url = `/_ajax/voting/vehicle/${code}`;
        this.getVehicle(url);
      }
    });

    // Fetching the vehicle based on selection field input by hand
    this.selectionTarget.addEventListener('keyup', () => this.debouncedGetVehicle())
    // this.selectionTarget.addEventListener('change', () => this.debouncedGetVehicle())
    this.cancelTarget.addEventListener('click', e => {
      this.voteActionContainerTarget.style.visibility = 'hidden'
    })

    // Clear the selection field and close the overlay once the form has been submitted
    this.votingFormTarget.addEventListener('submit', e => {
      this.voteActionContainerTarget.style.visibility = 'hidden'
    })
  }

  // Manage the QR code scanner
  handleScanner (preference) { 
    const state = this.scanner.getState()
    if (preference === 'scan') {
      if (state !== Html5QrcodeScannerState.SCANNING) {
        this.scanner.start(
            { facingMode: "environment" },
            { fps: 10, qrbox: 250 },
            (decodedText) => {
                this.selectionTarget.value = decodedText;
                scanner.stop(); // stop after success
            }
        );
      }
    } else {
      if (state === Html5QrcodeScannerState.SCANNING) {
        this.scanner.stop()
      }
    }
  }

  // Handle user choice of scanner or typing in data
  handleInputPreference () {
    const COOKIE_NAME = 'voting_input_preference'
    const inputPreference = Cookies.get(COOKIE_NAME) || 'scan'
    this.setInputPreference(inputPreference)
    this.handleScanner(inputPreference)
    const tabButtons = this.element.querySelectorAll('#voting-tabs button')
    tabButtons.forEach(b => {
      b.addEventListener('click', e => {
        const preference = e.target.getAttribute('aria-controls')
        Cookies.set(COOKIE_NAME, preference)
        this.setInputPreference(preference)
      })
    })
  }

  setInputPreference (preference) {
    const tabButtons = this.element.querySelectorAll('button[aria-controls]')
    const tabPanes = this.element.querySelectorAll('.tab-content .tab-pane')
    tabButtons.forEach(b => {
      if (b.getAttribute('aria-controls') === preference) {
        b.classList.add('active')
      } else {
        b.classList.remove('active')
      }
    })

    tabPanes.forEach(p => {
      if (p.id === preference) {
        p.classList.add('active')
      } else {
        p.classList.remove('active')
      }
    })
  }

  getVehicle (url) {
    fetch(url, { headers: this.getJsonHeaders() })
      .then(response => response.json())
      .then(data => {
        if (data.status === 'found') {
          this.voteActionContainerTarget.style.visibility = 'visible'
          this.selectionInfoTarget.innerHTML = data.vehicleInfo
          this.selectionWrapperTarget.style.display = 'flex'
          this.errorWrapperTarget.style.display = 'none'
        } else if (data.status === 'already selected') {
          this.voteActionContainerTarget.style.visibility = 'visible'
          this.errorInfoTarget.innerHTML = data.errorInfo
          this.selectionWrapperTarget.style.display = 'none'
          this.errorWrapperTarget.style.display = 'flex'
        } else {
          this.voteActionContainerTarget.style.visibility = 'hidden'
        }
      })
  }

  getBasicHeaders() {
    
    return {          
      "Content-Type": "application/json",
      "X-CSRF-Token": token
    }  
  }

  getJsonHeaders () {
    let token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    return {          
      "Content-Type": "application/json",
      "Accept": "application/json",
      "X-CSRF-Token": token
    }  
  }
}

