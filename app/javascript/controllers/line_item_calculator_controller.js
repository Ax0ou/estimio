// app/javascript/controllers/line_item_calculator_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "quantity", "pricePerUnit", "price" ]

  connect() {
    // console.log("Line item calculator connected");
    this.updateTotal(); // Calcul initial au cas où des valeurs sont déjà présentes
  }

  updateTotal() {
    const quantity = parseFloat(this.quantityTarget.value) || 0;
    const pricePerUnit = parseFloat(this.pricePerUnitTarget.value) || 0;
    const total = quantity * pricePerUnit;

    if (this.hasPriceTarget) {
      // Formate le total avec deux décimales
      this.priceTarget.value = total.toFixed(2);
    }
  }
}
