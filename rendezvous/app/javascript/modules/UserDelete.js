export class UserDelete extends HTMLElement {
  connectedCallback() {
    console.log("UserDelete connected");
    this.toggle = this.querySelector(".toggle");
    this.checkBoxes = this.querySelectorAll(".user-toggle");
    this.toggle.addEventListener("change", this.handleToggle);
  }

  disconnectedCallback() {
    this.toggle.removeEventListener("change", this.handleToggle);
  }

  handleToggle = (e) => {
    this.checkBoxes.forEach((cb) => {
      cb.checked = this.toggle.checked;
    });
  };
}
window.customElements.define("user-delete", UserDelete);
