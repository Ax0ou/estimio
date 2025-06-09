// app/javascript/controllers/description_expander_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "field" ]

  connect() {
    this.originalRows = this.fieldTarget.rows;
    this.fieldTarget.style.transition = "height 0.3s ease-in-out, background-color 0.3s ease-in-out";
    this.fieldTarget.style.overflow = "hidden"; // Pour éviter la barre de défilement pendant la transition
    // Ensure initial height is correctly set based on originalRows
    this.fieldTarget.style.height = this.calculateHeight(this.originalRows) + 'px';
  }

  handleMouseEnter() {
    this.expand();
  }

  handleMouseLeave() {
    if (document.activeElement !== this.fieldTarget) {
      this.collapseToOriginal();
    }
  }

  handleFocus() {
    this.expand();
  }

  handleBlur() {
    this.collapseToOriginal();
  }

  expand() {
    // Ensure rows attribute is sufficient before calculating scrollHeight for accuracy
    const currentLineHeight = this.calculateLineHeight();
    const currentScrollHeight = this.fieldTarget.scrollHeight;
    const neededRows = Math.max(this.originalRows, Math.ceil(currentScrollHeight / currentLineHeight));

    this.fieldTarget.rows = neededRows; // Set rows first
    this.fieldTarget.style.height = `${this.fieldTarget.scrollHeight}px`; // Then set height based on new scrollHeight
    this.fieldTarget.style.backgroundColor = "#f8f9fa"; // Un fond légèrement différent au survol/focus
  }

  collapseToOriginal() {
    this.fieldTarget.rows = this.originalRows;
    this.fieldTarget.style.height = this.calculateHeight(this.originalRows) + 'px';
    this.fieldTarget.style.backgroundColor = "";
  }

  calculateHeight(rows) {
    const lineHeight = this.calculateLineHeight();
    const paddingTop = parseFloat(getComputedStyle(this.fieldTarget).paddingTop) || 0;
    const paddingBottom = parseFloat(getComputedStyle(this.fieldTarget).paddingBottom) || 0;
    const borderTop = parseFloat(getComputedStyle(this.fieldTarget).borderTopWidth) || 0;
    const borderBottom = parseFloat(getComputedStyle(this.fieldTarget).borderBottomWidth) || 0;
    return (lineHeight * rows) + paddingTop + paddingBottom + borderTop + borderBottom;
  }

  calculateLineHeight() {
    const computedStyle = getComputedStyle(this.fieldTarget);
    let lineHeight = parseFloat(computedStyle.lineHeight);
    if (isNaN(lineHeight) || computedStyle.lineHeight === 'normal') {
      const tempElement = document.createElement('div');
      tempElement.style.fontSize = computedStyle.fontSize;
      tempElement.style.fontFamily = computedStyle.fontFamily;
      tempElement.style.lineHeight = 'normal';
      tempElement.innerHTML = 'A'; // Contenu non vide pour la mesure
      this.element.appendChild(tempElement); // Append to controller's element for proper styling context
      lineHeight = tempElement.offsetHeight;
      this.element.removeChild(tempElement);
    }
    return lineHeight || parseFloat(computedStyle.fontSize) * 1.2 || 16; // fallback based on font-size or a default
  }
}
