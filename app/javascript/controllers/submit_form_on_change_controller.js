import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="submit-form-on-change"
export default class extends Controller {
  connect() {
  }
  submit(event) {
    // Soumission directe du formulaire
    this.element.requestSubmit();
  }
}
