import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.adjust()
  }

  adjust() {
    this.element.style.height = "auto"
    this.element.style.height = `${this.element.scrollHeight}px`
  }

  resize() {
    this.adjust()
  }
}
