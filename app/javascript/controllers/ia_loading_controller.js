import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay"]

  show() {
    this.overlayTarget.style.display = "flex"
  }

  hide() {
    this.overlayTarget.style.display = "none"
    this.animation.stop()
  }
}
