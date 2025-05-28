import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "preview", "input"]
  static values = { quoteId: Number }

  connect() {
    this.recorder = null
    this.chunks = []
  }

  async toggleRecording() {
    if (!this.recorder || this.recorder.state === "inactive") {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      this.recorder = new MediaRecorder(stream)
      this.chunks = []

      this.recorder.ondataavailable = e => this.chunks.push(e.data)

      this.recorder.onstop = () => {
        const blob = new Blob(this.chunks, { type: "audio/webm" })
        const audioUrl = URL.createObjectURL(blob)
        this.previewTarget.src = audioUrl
        this.previewTarget.style.display = "block"

        this.blobToBase64(blob).then(base64 => {
          this.inputTarget.value = base64
        })
      }

      this.recorder.start()
      this.buttonTarget.textContent = "⏹ Stop Recording"
    } else {
      this.recorder.stop()
      this.buttonTarget.textContent = "🎙️ Start Recording"
    }
  }

  blobToBase64(blob) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader()
      reader.onloadend = () => resolve(reader.result.split(",")[1])
      reader.onerror = reject
      reader.readAsDataURL(blob)
    })
  }

  sendToTranscription() {
    const description = document.querySelector("input[name='ai_message[description]']").value
    const audioBase64 = this.inputTarget.value
    const quoteId = this.quoteIdValue

    fetch("/transcriptions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({
        description: description,
        audio: audioBase64
      })
    })
      .then(response => response.json())
      .then(data => {
        const fullText = data.transcription

        return fetch(`/quotes/${quoteId}/ai_messages`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
          },
          body: JSON.stringify({
            ai_message: {
              description: fullText
            }
          })
        })
      })
      .then(resp => {
        if (resp.ok) {
          alert("✅ Devis généré avec succès !")
          window.location.href = `/quotes/${this.quoteIdValue}`
        } else {
          alert("❌ Échec lors de l’envoi du devis.")
        }
      })
      .catch(error => {
        console.error("Erreur :", error)
        alert("❌ Une erreur est survenue.")
      })
  }
}
