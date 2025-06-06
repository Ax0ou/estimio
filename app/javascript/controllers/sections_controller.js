// app/javascript/controllers/sections_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "list", "newSectionFormContainer" ]

  connect() {
    // console.log("Sections controller connected");
  }

  showNewSectionForm() {
    if (this.hasNewSectionFormContainerTarget) {
      this.newSectionFormContainerTarget.style.display = "block";
      // Optionnel: cacher le bouton "+ Ajouter une section" pendant que le formulaire est visible
      // this.element.querySelector("[data-action*='showNewSectionForm']").style.display = "none";
    }
  }

  hideNewSectionForm() {
    if (this.hasNewSectionFormContainerTarget) {
      this.newSectionFormContainerTarget.style.display = "none";
      // Optionnel: réafficher le bouton "+ Ajouter une section"
      // this.element.querySelector("[data-action*='showNewSectionForm']").style.display = "block";
      // Vider le champ de description si le formulaire est caché
      const input = this.newSectionFormContainerTarget.querySelector("input[type='text']");
      if (input) {
        input.value = "";
      }
    }
  }

  submitForm(event) {
    // La soumission est gérée par turbo-stream, donc on veut juste cacher le formulaire après.
    // On attend un court instant pour s'assurer que la requête turbo a démarré.
    setTimeout(() => {
      this.hideNewSectionForm();
    }, 100);
  }
}
