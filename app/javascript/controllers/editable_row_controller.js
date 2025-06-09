// app/javascript/controllers/editable_row_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "form"]

  connect() {
    this.showDisplay()
  }

 edit() {
    this.displayTargets.forEach(el => el.classList.add("d-none"))
    this.formTargets.forEach(el => el.classList.remove("d-none"))
  }

  cancel() {
    this.formTargets.forEach(el => el.classList.add("d-none"))
    this.displayTargets.forEach(el => el.classList.remove("d-none"))
  }

  showDisplay() {
    this.displayTarget.classList.remove("d-none")
    this.formTarget.classList.add("d-none")
  }
}
