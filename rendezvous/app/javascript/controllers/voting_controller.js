import { Controller } from "@hotwired/stimulus"
import { debounce } from "throttle-debounce"
import { Html5Qrcode, Html5QrcodeScannerState } from "html5-qrcode"
import Cookies from "js-cookie"

const CODE_LENGTH = 6

export default class extends Controller {
  static targets = [
    "ballot", 
    "cancel", 
    "reader", 
    "selection", 
    "selectionInfo", 
    "voteActionContainer"
  ]

  connect () {
    this.main = document.querySelector('main')
    this.scanner = new Html5Qrcode(this.readerTarget.id)
    this.handleInputPreference()

    this.debouncedFetchInfo = debounce(500, () => {
      const code = this.selectionTarget.value;
      if (code.length === CODE_LENGTH) {
        const url = `/_ajax/voting/vehicle/${code}`;
        this.getInfo(url);
      }
    });

    this.selectionTarget.addEventListener('keyup', () => this.debouncedFetchInfo())
    this.cancelTarget.addEventListener('click', e => {
      this.voteActionContainerTarget.style.visibility = 'hidden'
    })
  }

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

  debouncedFetchInfo () {
    debounce(500, e => {
      const code = this.selectionTarget.value 
      if (code.trim().length === CODE_LENGTH) {
        const url = `/_ajax/voting/vehicle/${code}`
        this.getInfo(url)
      }
    })
  }

  getInfo (url) {
    fetch(url, { headers: this.getJsonHeaders() })
      .then(response => response.json())
      .then(data => {
        if (typeof data.vehicleInfo === "string") {
          this.voteActionContainerTarget.style.visibility = 'visible'
          this.selectionInfoTarget.innerHTML = data.vehicleInfo
        } else {
          this.voteContainer.style.visibility = 'hidden'
        }
      })
  }

  getBasicHeaders() {
    let token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    return {          
      "Content-Type": "application/json",
      "X-CSRF-Token": token
    }  
  }

  getJsonHeaders () {
    const headers = this.getBasicHeaders()
    headers['Accept'] = 'application/json'
    return headers
  }

  getTurboHeaders () {
    const headers = this.getBasicHeaders()
    headers['Accept'] = "text/vnd.turbo-stream.html"
    return headers
  }
}

