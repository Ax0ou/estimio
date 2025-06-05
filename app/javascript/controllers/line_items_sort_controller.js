import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["list"]
  static values = { url: String }

  connect() {
    this.sortable = Sortable.create(this.listTarget, {
      handle: ".handle",
      animation: 200,
      forceFallback: true,
      fallbackOnBody: true,
      ghostClass: "dragging",       // appliqué au clone qui suit la souris
      chosenClass: "chosen",        // appliqué à l'élément original au début du drag

      onStart: (evt) => {
        // Cache l'original juste après le drag
        setTimeout(() => {
          evt.item.classList.add("hidden-original")
        }, 0)
      },

      onEnd: (evt) => {
        evt.item.classList.remove("hidden-original")
        this.reorder()
      }
    })
  }

  reorder() {
    const ids = Array.from(this.listTarget.children).map(el => el.dataset.id)

    fetch(this.urlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ order: ids })
    })
  }
}
