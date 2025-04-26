import { Controller } from "@hotwired/stimulus"
import { debounce } from "throttle-debounce"
import { Html5Qrcode } from "html5-qrcode"
import Cookies from "js-cookie"

const CODE_LENGTH = 6

export default class extends Controller {
  static targets = ["reader", "selection", "ballot", "selectionInfo"]

  connect () {
    this.baseVoteUrl = `${window.location.origin}/_ajax/voting/ballots`
    this.handleInputPreference()

    this.debouncedFetchInfo = debounce(500, () => {
      const code = this.selectionTarget.value;
      if (code.length === CODE_LENGTH) {
        const url = `/_ajax/voting/vehicle/${code}`;
        this.getInfo(url);
      }
    });

    this.selectionTarget.addEventListener('keyup', () => this.debouncedFetchInfo())

    const scanner = new Html5Qrcode(this.readerTarget.id)
    scanner.start(
        { facingMode: "environment" },
        { fps: 10, qrbox: 250 },
        (decodedText) => {
            this.selectionTarget.value = decodedText;
            scanner.stop(); // stop after success
        }
    );
  }

  handleInputPreference () {
    const COOKIE_NAME = 'voting_input_preference'
    const inputPreference = Cookies.get(COOKIE_NAME) || 'scan'
    this.setInputPreference(inputPreference)
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
        if (typeof data.vehicleInfo === "string") 
            this.selectionInfoTarget.innerHTML = data.vehicleInfo
      })
  }

  // submitSelection(code) {
  //   const ballotId = this.element.dataset.ballotid
  //   const url = `${this.baseVoteUrl}/${ballotId}/${code}`
  //   fetch(url, {
  //     headers: {
  //       Accept: "text/vnd.turbo-stream.html"
  //     }
  //   })
  // }

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

