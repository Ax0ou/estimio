// app/javascript/controllers/ai_assistant_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sectionSelect", "description", "analyzeBtn", "recordBtn", "recordingIndicator", "results", "resultsContent"]
  static values = {
    quoteId: String,
    processing: Boolean,
    recording: Boolean,
    selectedSectionId: String
  }

  connect() {
    console.log("AI Assistant Controller connected")
    this.initializeAudioSupport()
  }

  disconnect() {
    if (this.mediaRecorder && this.mediaRecorder.state !== 'inactive') {
      this.mediaRecorder.stop()
    }
  }

  // === SÉLECTION DE SECTION ===
  selectSection(event) {
    const sectionId = event.target.value
    this.selectedSectionIdValue = sectionId

    if (sectionId) {
      this.showToast(`Section sélectionnée`, 'success')
      this.loadSectionContext(sectionId)
    }

    this.updateAnalyzeButtonState()
  }

  // === ANALYSE IA ===
  async analyzeDescription() {
    if (!this.canAnalyze()) {
      this.showToast('Veuillez sélectionner une section et saisir une description', 'warning')
      return
    }

    const description = this.descriptionTarget.value.trim()
    const sectionId = this.selectedSectionIdValue

    this.setProcessingState(true)

    try {
      const result = await this.callAIAPI(description, sectionId)
      this.displayResults(result)
      this.showToast('Analyse terminée avec succès!', 'success')
    } catch (error) {
      console.error('Erreur analyse IA:', error)
      this.showToast('Erreur lors de l\'analyse. Réessayez.', 'error')
    } finally {
      this.setProcessingState(false)
    }
  }

  // === ENREGISTREMENT VOCAL ===
  async initializeAudioSupport() {
    try {
      this.stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      console.log("Microphone autorisé")
    } catch (error) {
      console.warn("Microphone non disponible:", error)
      this.recordBtnTarget.disabled = true
      this.recordBtnTarget.title = "Microphone non disponible"
    }
  }

  async startRecording() {
    if (!this.stream) {
      this.showToast('Microphone non disponible', 'error')
      return
    }

    try {
      this.mediaRecorder = new MediaRecorder(this.stream)
      this.audioChunks = []
      this.recordingValue = true

      this.mediaRecorder.ondataavailable = (event) => {
        this.audioChunks.push(event.data)
      }

      this.mediaRecorder.onstop = async () => {
        const audioBlob = new Blob(this.audioChunks, { type: 'audio/wav' })
        await this.transcribeAudio(audioBlob)
      }

      this.mediaRecorder.start()
      this.showRecordingIndicator()
      this.showToast('Enregistrement démarré', 'info')

    } catch (error) {
      console.error('Erreur enregistrement:', error)
      this.showToast('Erreur lors du démarrage de l\'enregistrement', 'error')
    }
  }

  stopRecording() {
    if (this.mediaRecorder && this.mediaRecorder.state === 'recording') {
      this.mediaRecorder.stop()
      this.recordingValue = false
      this.hideRecordingIndicator()
      this.showToast('Enregistrement arrêté', 'info')
    }
  }

  // === MÉTHODES UTILITAIRES ===
  async callAIAPI(description, sectionId) {
    const response = await fetch(`/sections/${sectionId}/analyze_with_ai`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        description: description,
        context: { quote_id: this.quoteIdValue }
      })
    })

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }

    return await response.json()
  }

  async transcribeAudio(audioBlob) {
    const formData = new FormData()
    formData.append('audio', audioBlob, 'recording.wav')

    try {
      const response = await fetch('/ai/transcribe', {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: formData
      })

      if (response.ok) {
        const result = await response.json()
        if (result.success && result.transcript) {
          this.descriptionTarget.value = result.transcript
          this.showToast('Transcription réussie!', 'success')
          this.updateAnalyzeButtonState()
        }
      } else {
        throw new Error('Erreur de transcription')
      }
    } catch (error) {
      console.error('Erreur transcription:', error)
      this.showToast('Erreur lors de la transcription', 'error')
    }
  }

  async loadSectionContext(sectionId) {
    try {
      const response = await fetch(`/sections/${sectionId}.json`)
      if (response.ok) {
        const section = await response.json()
        console.log('Contexte de section chargé:', section)
        // Ici vous pouvez utiliser les données de la section
      }
    } catch (error) {
      console.warn('Impossible de charger le contexte de la section:', error)
    }
  }

  displayResults(result) {
    if (result.success && result.suggestions) {
      this.resultsContentTarget.innerHTML = `
        <div class="small">
          <strong>Suggestions:</strong><br>
          ${result.suggestions.map(item => `• ${item}`).join('<br>')}
        </div>
      `
      this.resultsTarget.style.display = 'block'

      // Nettoyer la description après succès
      this.descriptionTarget.value = ''
      this.updateAnalyzeButtonState()
    }
  }

  canAnalyze() {
    return this.selectedSectionIdValue &&
           this.descriptionTarget.value.trim().length > 10
  }

  updateAnalyzeButtonState() {
    const canAnalyze = this.canAnalyze()
    this.analyzeBtnTarget.disabled = !canAnalyze || this.processingValue

    if (this.processingValue) {
      this.analyzeBtnTarget.innerHTML = '<i class="bi bi-hourglass-split me-1"></i> Analyse...'
    } else {
      this.analyzeBtnTarget.innerHTML = '<i class="bi bi-magic me-1"></i> Analyser avec l\'IA'
    }
  }

  setProcessingState(processing) {
    this.processingValue = processing
    this.updateAnalyzeButtonState()
  }

  showRecordingIndicator() {
    this.recordingIndicatorTarget.style.display = 'block'
    this.recordBtnTarget.disabled = true
  }

  hideRecordingIndicator() {
    this.recordingIndicatorTarget.style.display = 'none'
    this.recordBtnTarget.disabled = false
  }

  showToast(message, type = 'info') {
    // Utilise votre système de notifications existant
    const toastContainer = document.querySelector('.toast-container') ||
                          this.createToastContainer()

    const toastElement = this.createToastElement(message, type)
    toastContainer.appendChild(toastElement)

    const toast = new bootstrap.Toast(toastElement)
    toast.show()

    toastElement.addEventListener('hidden.bs.toast', () => {
      toastElement.remove()
    })
  }

  createToastContainer() {
    const container = document.createElement('div')
    container.className = 'toast-container position-fixed bottom-0 end-0 p-3'
    container.style.zIndex = '1100'
    document.body.appendChild(container)
    return container
  }

  createToastElement(message, type) {
    const bgClass = {
      'success': 'bg-success',
      'error': 'bg-danger',
      'warning': 'bg-warning',
      'info': 'bg-info'
    }[type] || 'bg-info'

    const icon = {
      'success': 'bi-check-circle',
      'error': 'bi-x-circle',
      'warning': 'bi-exclamation-triangle',
      'info': 'bi-info-circle'
    }[type] || 'bi-info-circle'

    const toast = document.createElement('div')
    toast.className = `toast align-items-center ${bgClass} text-white border-0`
    toast.setAttribute('role', 'alert')
    toast.setAttribute('aria-live', 'assertive')
    toast.setAttribute('aria-atomic', 'true')

    toast.innerHTML = `
      <div class="d-flex">
        <div class="toast-body d-flex align-items-center">
          <i class="bi ${icon} me-2"></i>
          <span>${message}</span>
        </div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
      </div>
    `

    return toast
  }
}

// === FONCTIONS GLOBALES POUR COMPATIBILITÉ ===
window.selectSection = function(event) {
  // Trouve le contrôleur AI Assistant et appelle sa méthode
  const element = event.target.closest('[data-controller*="ai-assistant"]')
  if (element) {
    const controller = window.Stimulus.getControllerForElementAndIdentifier(element, 'ai-assistant')
    if (controller) {
      controller.selectSection(event)
    }
  }
}

window.analyzeDescription = function() {
  // Trouve le contrôleur AI Assistant et appelle sa méthode
  const element = document.querySelector('[data-controller*="ai-assistant"]')
  if (element) {
    const controller = window.Stimulus.getControllerForElementAndIdentifier(element, 'ai-assistant')
    if (controller) {
      controller.analyzeDescription()
    }
  }
}

window.startRecording = function() {
  // Trouve le contrôleur AI Assistant et appelle sa méthode
  const element = document.querySelector('[data-controller*="ai-assistant"]')
  if (element) {
    const controller = window.Stimulus.getControllerForElementAndIdentifier(element, 'ai-assistant')
    if (controller) {
      controller.startRecording()
    }
  }
}

window.stopRecording = function() {
  // Trouve le contrôleur AI Assistant et appelle sa méthode
  const element = document.querySelector('[data-controller*="ai-assistant"]')
  if (element) {
    const controller = window.Stimulus.getControllerForElementAndIdentifier(element, 'ai-assistant')
    if (controller) {
      controller.stopRecording()
    }
  }
}
