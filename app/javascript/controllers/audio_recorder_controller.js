import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["recordButton", "status", "preview", "textArea"]

  initialize() {
    this.mediaRecorder = null
    this.audioChunks = []
    this.isRecording = false
  }

  async toggle(event) {
    event.preventDefault()
    if (this.isRecording) {
      this.mediaRecorder.stop()
      this.isRecording = false
      this.statusTarget.textContent = "Envoi de la transcription..."
      this.recordButtonTarget.innerHTML = '<i class="bi bi-mic-fill me-2"></i> Enregistrer audio'
      this.recordButtonTarget.classList.remove("btn-danger")
      this.recordButtonTarget.classList.add("btn-outline-primary")
    } else {
      if (!navigator.mediaDevices) {
        alert("Enregistrement non pris en charge par ce navigateur.")
        return
      }
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      this.mediaRecorder = new MediaRecorder(stream)
      this.mediaRecorder.ondataavailable = e => this.audioChunks.push(e.data)
      this.mediaRecorder.onstop = this.onStop.bind(this)
      this.mediaRecorder.start()
      this.isRecording = true
      this.statusTarget.textContent = "Enregistrement..."
      this.recordButtonTarget.innerHTML = '<i class="bi bi-stop-fill me-2"></i> Arrêter'
      this.recordButtonTarget.classList.remove("btn-outline-primary")
      this.recordButtonTarget.classList.add("btn-danger")
    }
  }

  async onStop() {
    const audioBlob = new Blob(this.audioChunks, { type: "audio/webm" })
    this.audioChunks = []
    if (this.hasPreviewTarget) {
      const url = URL.createObjectURL(audioBlob)
      this.previewTarget.src = url
      this.previewTarget.style.display = "block"
    }
    const formData = new FormData()
    formData.append("audio", audioBlob, "audio.webm")
    try {
      const response = await fetch("/speech_to_text", {
        method: "POST",
        headers: { "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content },
        body: formData
      })
      const data = await response.json()
      if (data.text) {
        this.textAreaTarget.value = data.text
        this.statusTarget.textContent = ""
      } else {
        this.statusTarget.textContent = "Erreur lors de la transcription."
      }
    } catch (e) {
      this.statusTarget.textContent = "Erreur de connexion lors de la transcription."
    }
  }
}
