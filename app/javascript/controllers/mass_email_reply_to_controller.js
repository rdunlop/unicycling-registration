import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "additional", "display"]
  static values = { contactEmail: String, userEmail: String }

  connect() {
    this.update()
  }

  update() {
    const addresses = [this.contactEmailValue]

    if (this.checkboxTarget.checked) {
      addresses.push(this.userEmailValue)
    }

    this.additionalTarget.value
      .split(",")
      .map((email) => email.trim())
      .filter((email) => email.length > 0)
      .forEach((email) => addresses.push(email))

    this.displayTarget.textContent = [...new Set(addresses)].join(", ")
  }
}
