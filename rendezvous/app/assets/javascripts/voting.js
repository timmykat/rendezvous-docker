class VotingApp extends HTMLElement {

  init () {
    this.selectionField = this.getElementById("selection");
    this.qrScanner = new Html5Qrcode("reader");
    const ballotId = this.getAttribute('data-ballot-id')
    this.fetchUrl = window.location.origin + "/_ajax/voting/select/" + ballotId 
    this.selectionInfo = this.querySelector('.selection-info')
  }

  connectedCallback () {
    this.init();
    this.qrScanner.start(
        { facingMode: "environment" },
        { fps: 10, qrbox: 250 },
        (decodedText) => {
            selectionField.value = decodedText;
            qrScanner.stop(); // stop after success
            this.registerSelection(decodedText);
        }
    );
  }

  registerSelection (vehicleId) {
    const url = this.fetchUrl + '/' + vehicleId
    fetch(url, {headers: getCsrfHeaders})
      .then(response => response.json())
      .then(data => {
        this.updateAfterSelection(data)
      })
  }

  updateAfterSelection (data) {
    this.selectionInfo.innerHTML = data.selected_vehicle
  }
}