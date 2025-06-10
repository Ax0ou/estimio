import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  search() {
    fetch(`${this.formTarget.action}?query=${encodeURIComponent(this.formTarget.querySelector("input").value)}`, {
      headers: {
        Accept: "text/vnd.turbo-stream.html"
      },
      method: "GET"
    }).then(response => response.text())
      .then(html => {
        const container = document.getElementById("products")
        if (container) {
          container.innerHTML = html
        }
      })
  }

}
