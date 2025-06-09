import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textArea", "recordButton", "status", "liveTranscription", "liveText"]

  connect() {
    this.mediaRecorder = null
    this.audioChunks = []
    this.isRecording = false
    this.stream = null
    this.recognition = null
    this.setupSpeechRecognition()
  }

  setupSpeechRecognition() {
    console.log('Setting up speech recognition...')
    if ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window) {
      console.log('Speech recognition is supported')
      const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
      this.recognition = new SpeechRecognition()
      
      this.recognition.continuous = true
      this.recognition.interimResults = true
      this.recognition.lang = 'fr-FR'
      
      let finalTranscript = ''
      
      this.recognition.onresult = (event) => {
        console.log('Speech recognition result:', event)
        let interimTranscript = ''
        
        for (let i = event.resultIndex; i < event.results.length; i++) {
          const transcript = event.results[i][0].transcript
          console.log('Transcript:', transcript, 'isFinal:', event.results[i].isFinal)
          
          if (event.results[i].isFinal) {
            finalTranscript += transcript + ' '
          } else {
            interimTranscript += transcript
          }
        }
        
        console.log('Final:', finalTranscript, 'Interim:', interimTranscript)
        // Afficher la transcription en temps réel
        this.updateLiveTranscription(finalTranscript, interimTranscript)
        
        // Mettre à jour le textarea avec le texte final
        this.textAreaTarget.value = finalTranscript.trim()
      }
      
      this.recognition.onerror = (event) => {
        console.error('Erreur de reconnaissance vocale:', event.error)
        alert('Erreur de reconnaissance vocale: ' + event.error)
      }
      
      this.recognition.onstart = () => {
        console.log('Speech recognition started')
      }
      
      this.recognition.onend = () => {
        console.log('Speech recognition ended')
        this.hideLiveTranscription()
      }
    } else {
      console.log('Speech recognition not supported')
      alert('La reconnaissance vocale n\'est pas supportée par votre navigateur')
    }
  }

  updateLiveTranscription(finalText, interimText) {
    console.log('Updating live transcription, hasLiveTextTarget:', this.hasLiveTextTarget)
    if (this.hasLiveTextTarget) {
      const displayText = finalText + '<span class="text-muted">' + interimText + '</span>'
      console.log('Setting innerHTML to:', displayText)
      this.liveTextTarget.innerHTML = displayText
    } else {
      console.log('No liveTextTarget found')
    }
  }

  showLiveTranscription() {
    console.log('Showing live transcription, hasLiveTranscriptionTarget:', this.hasLiveTranscriptionTarget)
    if (this.hasLiveTranscriptionTarget) {
      this.liveTranscriptionTarget.style.display = 'block'
      if (this.hasLiveTextTarget) {
        this.liveTextTarget.innerHTML = ''
      }
    } else {
      console.log('No liveTranscriptionTarget found')
    }
  }

  hideLiveTranscription() {
    if (this.hasLiveTranscriptionTarget) {
      this.liveTranscriptionTarget.style.display = 'none'
    }
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

      // Démarrer la reconnaissance vocale en temps réel
      if (this.recognition) {
        console.log('Starting speech recognition...')
        this.showLiveTranscription()
        this.recognition.start()
      } else {
        console.log('No speech recognition available')
      }

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

      // Arrêter la reconnaissance vocale
      if (this.recognition) {
        this.recognition.stop()
      }

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
