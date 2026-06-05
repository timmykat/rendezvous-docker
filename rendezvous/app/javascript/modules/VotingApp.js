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
    this.duplicateWarning = this.querySelector(".previously-selected");
    this.voteButton = this.querySelector("#vote-button");
    this.voteButton.disabled = true;
  }

  connectedCallback() {
    document.addEventListener("turbo:load", this.setTab);
    document.addEventListener("turbo:load", this.saveData);
    this.codeField.addEventListener("keyup", this.fetchVehicleData);
  }

  disconnectedCallback() {
    document.removeEventListener("turbo:load", this.setTab);
    document.removeEventListener("turbo:load", this.saveData);
    this.codeField.removeEventListener("keyup", this.fetchVehicleData);
  }

  reset = () => {
    this.voteButton.disabled = true;
    this.duplicateWarning.setAttribute("hidden");
    this.selectionInfo.style.visibility = "hidden";
    this.categoryValue.textContent = "";
    this.vehicle.textContent = "";
    this.ownerValue.textContent = "";
  };

  fetchVehicleData = (e) => {
    const codeInput = this.codeField;
    const code = codeInput.value.toUpperCase().trim();
    const regex = /^[A-Z0-9]{4}$/;
    if (!regex.test(code)) {
      this.duplicateWarning.setAttribute("hidden", "");
      this.reset();
      return;
    }

    if (selectedCodes.includes(code)) {
      this.duplicateWarning.removeAttribute("hidden");
      this.voteButton.disabled = true;
    } else {
      this.duplicateWarning.setAttribute("hidden", "");
    }

    const url = `${this.baseUrl}/${code}`;
    fetch(url)
      .then((response) => response.json())
      .then((data) => {
        if (data.status !== "ok") {
          console.log("Not ok", data.status);
          this.codeField.value = "";
          return;
        }
        this.categoryValue.textContent = data.category;
        this.vehicle.textContent = data.vehicle;
        this.ownerValue.textContent = data.owner;
        this.selectionInfo.style.visibility = "visible";
        if (!selectedCodes.includes(code)) {
          this.voteButton.disabled = false;
        }
      });
  };

  saveData = () => {
    window.localStorage.setItem(
      "RDV.ballotData",
      JSON.stringify(window.ballotData),
    );
    window.localStorage.setItem(
      "RDV.selectedCodes",
      JSON.stringify(selectedCodes),
    );
  };

  setTab = () => {
    const tabDisplay = this.querySelector("tab-display");
    if (!tabDisplay) return;

    tabDisplay.setTab("vote");
  };
}
customElements.define("voting-app", VotingApp);
