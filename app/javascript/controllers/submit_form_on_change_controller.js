import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="submit-form-on-change"
export default class extends Controller {
  connect() {
  }
  submit(event) {
    const btn  = this.element.querySelector("input[type='submit']")
    if (!btn) return;

    btn.click();
    // this.element.submit();

  }
}
