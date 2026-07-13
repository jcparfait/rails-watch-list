import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "indicator"]
  static values = {
    text: String
  }

  submit() {
    if (!this.element.checkValidity()) return

    this.element.classList.add("is-loading")
    this.showIndicator()
    this.disableButton()
  }

  showIndicator() {
    if (!this.hasIndicatorTarget) return

    this.indicatorTarget.classList.remove("d-none")
  }

  disableButton() {
    if (!this.hasButtonTarget) return

    const label = this.textValue || "Loading..."
    this.buttonTarget.disabled = true

    if (this.buttonTarget.tagName === "INPUT") {
      this.buttonTarget.value = label
    } else {
      this.buttonTarget.textContent = label
    }
  }
}
