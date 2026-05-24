export class VotingApp extends HTMLElement {
  connectedCallback() {
    console.log("Connected");
    document.addEventListener("turbo:load", this.saveData);
  }

  disconnectedCallback() {
    console.log("Disconnected");
    document.removeEventListener("turbo:load", this.saveData);
  }

  saveData = () => {
    console.log("Saving");
    window.localStorage.setItem("RDV.ballotData", JSON.stringify(ballotData));
  };
}
customElements.define("voting-app", VotingApp);
