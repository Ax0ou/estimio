import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textArea", "recordButton", "status"]

  connect() {
    this.mediaRecorder = null
    this.audioChunks = []
    this.isRecording = false
    this.stream = null
  }

  async toggle() {
    if (this.isRecording) {
      this.stopRecording()
    } else {
      await this.startRecording()
    }
  }

  async startRecording() {
    if (!navigator.mediaDevices) {
      alert("L'enregistrement audio n'est pas supporté par ce navigateur.")
      return
    }

    try {
      this.audioChunks = []
      this.stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      this.mediaRecorder = new MediaRecorder(this.stream)

      this.mediaRecorder.ondataavailable = e => this.audioChunks.push(e.data)
      this.mediaRecorder.onstop = () => this.handleRecordingStop()

      this.mediaRecorder.start()
      this.isRecording = true

      this.recordButtonTarget.innerHTML = '<i class="bi bi-stop-fill"></i>'
      this.recordButtonTarget.classList.remove("btn-outline-secondary")
      this.recordButtonTarget.classList.add("btn-danger")
      this.statusTarget.style.display = "inline"

    } catch (error) {
      alert("Erreur lors de l'accès au microphone: " + error.message)
    }
  }

  stopRecording() {
    if (this.mediaRecorder && this.isRecording) {
      this.mediaRecorder.stop()
      if (this.stream) {
        this.stream.getTracks().forEach(track => track.stop())
      }
      this.isRecording = false

      this.recordButtonTarget.innerHTML = '<i class="bi bi-mic-fill"></i>'
      this.recordButtonTarget.classList.remove("btn-danger")
      this.recordButtonTarget.classList.add("btn-outline-secondary")
      this.statusTarget.style.display = "none"
    }
  }

  async handleRecordingStop() {
    const audioBlob = new Blob(this.audioChunks, { type: "audio/webm" })
    await this.transcribeToText(audioBlob)
  }

  async transcribeToText(audioBlob) {
    try {
      const formData = new FormData()
      formData.append("audio", audioBlob, "audio.webm")

      const sectionId = this.element.closest('.section').id.split('-')[1]

      const response = await fetch(`/sections/${sectionId}/transcribe_audio`, {
        method: "POST",
        body: formData,
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        }
      })

      const data = await response.json()
      if (data.text) {
        this.textAreaTarget.value = data.text
      } else {
        alert("Erreur lors de la transcription.")
      }
    } catch (error) {
      alert("Erreur lors de la transcription: " + error.message)
    }
  }
}
