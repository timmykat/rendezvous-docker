import { Controller } from "@hotwired/stimulus"
import { debounce } from "throttle-debounce"
import { Html5Qrcode } from "html5-qrcode"

const CODE_LENGTH = 6

export default class extends Controller {
  static targets = ["reader", "selection", "ballot", "selectionInfo"]

  connect () {
    console.log('Voting controller connected')
    this.baseVoteUrl = `${window.location.origin}/_ajax/voting/ballots`

    this.debouncedFetchInfo = debounce(500, () => {
      const code = this.selectionTarget.value;
      if (code.length === CODE_LENGTH) {
        const url = `/_ajax/voting/vehicle/${code}`;
        this.getInfo(url);
      }
    });

    // this.addButtonTarget.addEventListener('click', () => {
    //   console.log('Clicked vote')
    //   const code = this.selectionTarget.value
    //   this.submitSelection(code)
    // })

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

  updateAction(event) {
    console.log(event)
    const code = this.selectionTarget.value.trim()
    const id = this.ballotTarget.value

    const form = event.target
    form.action = `/_ajax/voting/ballots/${id}/${encodeURIComponent(code)}`
    console.log(form)
    form.submit()
  }
}

