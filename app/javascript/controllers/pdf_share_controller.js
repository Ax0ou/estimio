import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { data: Object }

  async fire() {
    const { title, text, file_url } = this.dataValue

    if (!file_url) {
      alert("Aucune URL de fichier à partager.")
      return
    }

    try {
      const response = await fetch(file_url)
      const blob = await response.blob()
      const file = new File([blob], "devis_estimio.pdf", { type: "application/pdf" })

      const shareData = {
        title,
        text,
        files: [file]
      }

      if (navigator.canShare?.(shareData)) {
        await navigator.share(shareData)
      } else {
        alert("Le partage de fichiers n’est pas supporté sur ce navigateur.")
      }
    } catch (error) {
      console.error("Erreur lors du partage :", error)
      alert("Impossible de partager le fichier.")
    }
  }
}
