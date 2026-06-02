export class VotingApp extends HTMLElement {
  constructor() {
    super();
    this.codeField = this.querySelector("input#selection_code");
    this.errorModal = document.querySelector(".modal#duplicate-error");
    this.baseUrl = "/_ajax/vehicle_info";
    this.selectionInfo = this.querySelector(".selection-info");
    this.categoryValue = this.selectionInfo.querySelector(".category .value");
    this.vehicle = this.selectionInfo.querySelector(".info .vehicle");
    this.ownerValue = this.selectionInfo.querySelector(".info .owner .value");
  }

  connectedCallback() {
    document.addEventListener("turbo:load", this.saveData);
    this.codeField.addEventListener("keyup", this.fetchVehicleData);
  }

  disconnectedCallback() {
    console.log("Disconnected");
    document.removeEventListener("turbo:load", this.saveData);
    this.codeField.removeEventListener("keyup", this.fetchVehicleData);
  }

  fetchVehicleData = (e) => {
    const codeInput = this.codeField;
    const code = codeInput.value.toUpperCase().trim();
    const regex = /^[A-Z0-9]{4}$/;
    if (!regex.test(code)) return;

    if (selectedCodes.contains(code)) {
      this.errorModal.style.display = "block";
    }

    const url = `${this.baseUrl}/${code}`;
    console.log("Fetching", url);
    fetch(url)
      .then((response) => response.json())
      .then((data) => {
        console.log("Data", data);
        if (data.status !== "ok") {
          console.log("Not ok", data.status);
          this.codeField.value = "";
          return;
        }
        this.categoryValue.textContent = data.category;
        this.vehicle.textContent = data.vehicle;
        this.ownerValue.textContent = data.owner;
        this.selectionInfo.style.visibility = "visible";
      });
  };

  saveData = () => {
    window.localStorage.setItem("RDV.ballotData", JSON.stringify(ballotData));
    window.localStorage.setItem(
      "RDV.selectedCodes",
      JSON.stringify(selectedCodes),
    );
  };
}
customElements.define("voting-app", VotingApp);
