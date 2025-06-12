// app/javascript/controllers/sidebar_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "sectionSelect", "description", "analyzeButton", "analyzeButtonText", 
    "aiNotes", "statusIndicator", "statusText",
    "recordButton", "recordButtonText", "stopButton", "recordingIndicator"
  ]
  static values = { 
    processing: Boolean,
    sectionId: String,
    recording: Boolean,
    quoteId: String
  }

  connect() {
    console.log("Sidebar controller connected")
    this.initializeTooltips()
    this.updateAnalyzeButtonState()
    this.initializeAudioRecorder()
    this.autoSaveTimeout = null
  }

  disconnect() {
    if (this.mediaRecorder && this.mediaRecorder.state !== 'inactive') {
      this.mediaRecorder.stop()
    }
    if (this.autoSaveTimeout) {
      clearTimeout(this.autoSaveTimeout)
    }
  }

  // === GESTION DE LA SÉLECTION DE SECTION ===
  sectionChanged() {
    const selectedSectionId = this.sectionSelectTarget.value
    this.sectionIdValue = selectedSectionId
    this.updateAnalyzeButtonState()
    
    if (selectedSectionId) {
      this.loadSectionContext(selectedSectionId)
      this.showStatus("Section sélectionnée - Prêt pour l'analyse", "info")
    } else {
      this.hideStatus()
    }
  }

  // === GESTION DE LA DESCRIPTION ===
  descriptionChanged() {
    this.updateAnalyzeButtonState()
    this.autoExpandTextarea()
    
    // Validation en temps réel
    const description = this.descriptionTarget.value.trim()
    if (description.length > 10) {
      this.descriptionTarget.classList.add('is-valid')
      this.descriptionTarget.classList.remove('is-invalid')
    } else if (description.length > 0) {
      this.descriptionTarget.classList.add('is-invalid')
      this.descriptionTarget.classList.remove('is-valid')
    } else {
      this.descriptionTarget.classList.remove('is-valid', 'is-invalid')
    }
  }

  autoSave() {
    // Auto-sauvegarde de la description (debounced)
    if (this.autoSaveTimeout) {
      clearTimeout(this.autoSaveTimeout)
    }
    
    this.autoSaveTimeout = setTimeout(() => {
      const description = this.descriptionTarget.value.trim()
      if (description.length > 0) {
        localStorage.setItem(`sidebar_description_${this.quoteIdValue}`, description)
      }
    }, 1000)
  }

  clearDescription() {
    this.descriptionTarget.value = ''
    this.descriptionTarget.classList.remove('is-valid', 'is-invalid')
    this.updateAnalyzeButtonState()
    this.autoExpandTextarea()
    this.hideStatus()
    
    // Effacer aussi l'auto-sauvegarde
    localStorage.removeItem(`sidebar_description_${this.quoteIdValue}`)
  }

  // === ANALYSE IA ===
  async analyzeDescription(event) {
    event.preventDefault()
    
    if (!this.canAnalyze()) {
      this.showStatus("Veuillez sélectionner une section et saisir une description", "error")
      return
    }

    const description = this.descriptionTarget.value.trim()
    const sectionId = this.sectionIdValue

    this.setProcessingState(true)
    this.showStatus("Analyse en cours par l'IA...", "processing")
    
        try {
      const result = await this.callAIAnalysis(description, sectionId)
      this.displayAnalysisResult(result)
      this.showStatus("Analyse terminée avec succès !", "success")
    } catch (error) {
      console.error("Erreur d'analyse IA:", error)
      this.showStatus("Erreur lors de l'analyse. Veuillez réessayer.", "error")
    } finally {
      this.setProcessingState(false)
      setTimeout(() => this.hideStatus(), 3000)
    }
  }

  async callAIAnalysis(description, sectionId) {
    // Appel à votre API d'analyse IA
    const response = await fetch(`/sections/${sectionId}/analyze_with_ai`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        description: description,
        context: this.gatherContext()
      })
    })

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }

    return await response.json()
  }

  displayAnalysisResult(result) {
    if (result.success) {
      // Afficher les notes de l'IA
      if (this.hasAiNotesTarget && result.notes) {
        this.aiNotesTarget.value = result.notes
      }
      
      // Déclencher l'ajout des line items via Turbo
      if (result.line_items && result.line_items.length > 0) {
        this.addLineItemsToSection(result.line_items)
      }
      
      // Effacer la description après analyse réussie
      this.clearDescription()
      
      // Notification de succès
      this.showSuccessToast(`${result.line_items.length} éléments ajoutés à la section`)
    }
  }

  // === ENREGISTREMENT VOCAL ===
  async initializeAudioRecorder() {
    try {
      this.stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      console.log("Micro autorisé")
    } catch (error) {
      console.warn("Micro non disponible:", error)
      this.disableVoiceFeatures()
    }
  }

  async startRecording() {
    if (!this.stream) {
      this.showStatus("Microphone non disponible", "error")
      return
    }

    try {
      this.mediaRecorder = new MediaRecorder(this.stream)
      this.audioChunks = []

      this.mediaRecorder.ondataavailable = (event) => {
        this.audioChunks.push(event.data)
      }

      this.mediaRecorder.onstop = () => {
        this.processRecording()
      }

      this.mediaRecorder.start()
      this.setRecordingState(true)
      this.showStatus("Enregistrement en cours... Parlez maintenant", "recording")

    } catch (error) {
      console.error("Erreur d'enregistrement:", error)
      this.showStatus("Erreur lors du démarrage de l'enregistrement", "error")
    }
  }

  stopRecording() {
    if (this.mediaRecorder && this.mediaRecorder.state === 'recording') {
      this.mediaRecorder.stop()
    }
    this.setRecordingState(false)
    this.showStatus("Traitement de l'enregistrement...", "processing")
  }

  async processRecording() {
    const audioBlob = new Blob(this.audioChunks, { type: 'audio/wav' })
    
    try {
      const transcript = await this.transcribeAudio(audioBlob)
      
      if (transcript && transcript.trim().length > 0) {
        // Ajouter le texte transcrit à la description
        const currentDescription = this.descriptionTarget.value
        const newDescription = currentDescription 
          ? `${currentDescription}\n\n${transcript}` 
          : transcript
        
        this.descriptionTarget.value = newDescription
        this.descriptionChanged()
        this.showStatus("Transcription ajoutée avec succès", "success")
      } else {
        this.showStatus("Aucun texte détecté dans l'enregistrement", "warning")
      }
    } catch (error) {
      console.error("Erreur de transcription:", error)
      this.showStatus("Erreur lors de la transcription", "error")
    }
    
    setTimeout(() => this.hideStatus(), 3000)
  }

  async transcribeAudio(audioBlob) {
    // Appel à votre API de transcription
    const formData = new FormData()
    formData.append('audio', audioBlob, 'recording.wav')

    const response = await fetch('/ai/transcribe', {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: formData
    })

    if (!response.ok) {
      throw new Error(`Transcription failed: ${response.statusText}`)
    }

    const result = await response.json()
    return result.transcript
  }

  // === GESTION DES ÉTATS ===
  setProcessingState(processing) {
    this.processingValue = processing
    this.updateAnalyzeButtonState()
    
    if (processing) {
      this.element.classList.add('processing')
      this.analyzeButtonTextTarget.textContent = "Analyse en cours..."
    } else {
      this.element.classList.remove('processing')
      this.analyzeButtonTextTarget.textContent = "Analyser avec l'IA"
    }
  }

  setRecordingState(recording) {
    this.recordingValue = recording
    
    if (recording) {
      this.recordButtonTarget.style.display = 'none'
      this.stopButtonTarget.style.display = 'block'
      this.recordingIndicatorTarget.style.display = 'flex'
      this.recordButtonTarget.classList.add('recording')
    } else {
      this.recordButtonTarget.style.display = 'block'
      this.stopButtonTarget.style.display = 'none'
      this.recordingIndicatorTarget.style.display = 'none'
      this.recordButtonTarget.classList.remove('recording')
    }
  }

  showStatus(message, type = "info") {
    if (!this.hasStatusIndicatorTarget) return
    
    const indicator = this.statusIndicatorTarget
    const text = this.statusTextTarget
    
    // Réinitialiser les classes
    indicator.className = `alert py-2 px-3 mb-3`
    
    // Appliquer le style selon le type
    switch(type) {
      case 'success':
        indicator.classList.add('alert-success')
        text.innerHTML = `<i class="bi bi-check-circle me-2"></i>${message}`
        break
      case 'error':
        indicator.classList.add('alert-danger')
        text.innerHTML = `<i class="bi bi-exclamation-triangle me-2"></i>${message}`
        break
      case 'warning':
        indicator.classList.add('alert-warning')
        text.innerHTML = `<i class="bi bi-exclamation-circle me-2"></i>${message}`
        break
      case 'recording':
        indicator.classList.add('alert-danger')
        text.innerHTML = `<i class="bi bi-record-circle me-2"></i>${message}`
        break
      case 'processing':
        indicator.classList.add('alert-info')
        text.innerHTML = `<i class="bi bi-hourglass-split me-2"></i>${message}`
        break
      default:
        indicator.classList.add('alert-info')
        text.innerHTML = `<i class="bi bi-info-circle me-2"></i>${message}`
    }
    
    indicator.style.display = 'block'
  }

  hideStatus() {
    if (this.hasStatusIndicatorTarget) {
      this.statusIndicatorTarget.style.display = 'none'
    }
  }

  // === UTILITAIRES ===
  updateAnalyzeButtonState() {
    const hasDescription = this.descriptionTarget.value.trim().length > 10
    const hasSection = this.sectionIdValue !== ''
    const canAnalyze = hasDescription && hasSection && !this.processingValue
    
    if (this.hasAnalyzeButtonTarget) {
      this.analyzeButtonTarget.disabled = !canAnalyze
    }
  }

  canAnalyze() {
    return this.descriptionTarget.value.trim().length > 10 && 
           this.sectionIdValue !== '' && 
           !this.processingValue
  }

  autoExpandTextarea() {
    const textarea = this.descriptionTarget
    textarea.style.height = 'auto'
    textarea.style.height = Math.min(textarea.scrollHeight, 200) + 'px'
  }

  gatherContext() {
    return {
      section_id: this.sectionIdValue,
      quote_id: this.quoteIdValue,
      existing_items_count: document.querySelectorAll(`[data-section-id="${this.sectionIdValue}"] .line-item-card`).length
    }
  }

  loadSectionContext(sectionId) {
    // Charger du contexte spécifique à la section si nécessaire
    console.log(`Loading context for section ${sectionId}`)
  }

  addLineItemsToSection(lineItems) {
    // Déclencher l'ajout via Turbo Stream ou formulaire
    // Cette méthode dépend de votre implémentation Rails existante
    console.log("Adding line items:", lineItems)
  }

  showHistory() {
    // Afficher l'historique des analyses
    this.showStatus("Fonctionnalité en développement", "info")
  }

  toggleAdvancedOptions() {
    // Géré automatiquement par Bootstrap collapse
  }

  disableVoiceFeatures() {
    if (this.hasRecordButtonTarget) {
      this.recordButtonTarget.disabled = true
      this.recordButtonTarget.title = "Microphone non disponible"
    }
  }

  initializeTooltips() {
    const tooltipTriggerList = this.element.querySelectorAll('[data-bs-toggle="tooltip"]')
    const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => 
      new bootstrap.Tooltip(tooltipTriggerEl)
    )
  }

  showSuccessToast(message) {
    // Utiliser votre système de toasts existant
    this.showToast(message, 'success')
  }

  showToast(message, type = 'info') {
    const toastContainer = document.querySelector('.toast-container') || this.createToastContainer()
    
    const toastElement = document.createElement('div')
    toastElement.className = `toast align-items-center text-white bg-${this.getBootstrapColorClass(type)} border-0`
    toastElement.setAttribute('role', 'alert')
    toastElement.innerHTML = `
      <div class="d-flex">
        <div class="toast-body">
          <i class="bi bi-${this.getIconClass(type)} me-2"></i>
          ${message}
        </div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
      </div>
    `
    
    toastContainer.appendChild(toastElement)
    const toast = new bootstrap.Toast(toastElement, { delay: 4000 })
    toast.show()
    
    toastElement.addEventListener('hidden.bs.toast', () => {
      toastElement.remove()
    })
  }

  createToastContainer() {
    const container = document.createElement('div')
    container.className = 'toast-container position-fixed top-0 end-0 p-3'
    document.body.appendChild(container)
    return container
  }

  getBootstrapColorClass(type) {
    const classes = {
      'success': 'success',
      'error': 'danger',
      'warning': 'warning',
      'info': 'primary'
    }
    return classes[type] || 'primary'
  }

  getIconClass(type) {
    const icons = {
      'success': 'check-circle',
      'error': 'exclamation-triangle',
      'warning': 'exclamation-triangle',
      'info': 'info-circle'
    }
    return icons[type] || 'info-circle'
  }
}
      })
      .catch(error => {
        console.error("Erreur d'analyse IA:", error)
        this.showError("Une erreur s'est produite lors de l'analyse")
      })
      .finally(() => {
        this.setProcessingState(false)
      })
  }

  // Effacer la description
  clearDescription() {
    this.descriptionTarget.value = ''
    this.updateAnalyzeButtonState()
    this.autoExpandTextarea()
  }

  // Toggle des options avancées
  toggleAdvancedOptions() {
    const collapseElement = document.getElementById('aiAdvancedOptions')
    const collapse = new bootstrap.Collapse(collapseElement)
  }

  // Fonctions utilitaires privées

  updateAnalyzeButtonState() {
    const hasDescription = this.descriptionTarget.value.trim().length > 0
    const hasSection = this.sectionIdValue !== ''
    const canAnalyze = hasDescription && hasSection && !this.processingValue

    if (this.hasAnalyzeButtonTarget) {
      this.analyzeButtonTarget.disabled = !canAnalyze

      if (this.processingValue) {
        this.analyzeButtonTarget.innerHTML = '<i class="bi bi-hourglass-split me-1"></i>Analyse...'
      } else {
        this.analyzeButtonTarget.innerHTML = '<i class="bi bi-magic me-1"></i>Analyser'
      }
    }
  }

  setProcessingState(processing) {
    this.processingValue = processing
    this.updateAnalyzeButtonState()

    // Ajouter une classe visuelle de processing
    if (processing) {
      this.element.classList.add('processing')
    } else {
      this.element.classList.remove('processing')
    }
  }

  canAnalyze() {
    return this.descriptionTarget.value.trim().length > 0 &&
           this.sectionIdValue !== '' &&
           !this.processingValue
  }

  autoExpandTextarea() {
    const textarea = this.descriptionTarget
    textarea.style.height = 'auto'
    textarea.style.height = Math.min(textarea.scrollHeight, 150) + 'px'
  }

  async callAIAnalysis(description, sectionId) {
    // Simuler un délai d'API
    await new Promise(resolve => setTimeout(resolve, 1500))

    // Simulation de réponse - remplacer par votre vraie API
    return {
      success: true,
      items: [
        { description: "Main d'œuvre spécialisée", quantity: 8, unit: "h", price: 45 },
        { description: "Matériau principal", quantity: 20, unit: "m²", price: 25 }
      ],
      notes: "Analyse basée sur la description fournie. Vérifiez les quantités."
    }
  }

  displayAnalysisResult(result) {
    if (result.success) {
      // Afficher une notification de succès
      this.showSuccess("Analyse terminée ! Les éléments ont été ajoutés.")

      // Optionnel : afficher les notes IA
      if (this.hasAiNotesTarget && result.notes) {
        this.aiNotesTarget.value = result.notes
      }

      // Effacer la description après analyse réussie
      this.clearDescription()
    }
  }

  loadSectionContext(sectionId) {
    // Optionnel : charger du contexte spécifique à la section
    console.log(`Loading context for section ${sectionId}`)
  }

  initializeTooltips() {
    // Initialiser les tooltips Bootstrap pour les éléments tronqués
    const tooltipTriggerList = this.element.querySelectorAll('[data-bs-toggle="tooltip"]')
    const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl))
  }

  showSuccess(message) {
    // Utiliser votre système de toasters
    this.showToast(message, 'success')
  }

  showError(message) {
    // Utiliser votre système de toasters
    this.showToast(message, 'error')
  }

  showToast(message, type = 'info') {
    // Créer un toast Bootstrap (à adapter selon votre système)
    const toastContainer = document.querySelector('.toast-container') || document.body

    const toastElement = document.createElement('div')
    toastElement.className = `toast align-items-center text-white bg-${type === 'success' ? 'success' : 'danger'} border-0`
    toastElement.setAttribute('role', 'alert')
    toastElement.innerHTML = `
      <div class="d-flex">
        <div class="toast-body">${message}</div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
      </div>
    `

    toastContainer.appendChild(toastElement)
    const toast = new bootstrap.Toast(toastElement)
    toast.show()

    // Nettoyer après disparition
    toastElement.addEventListener('hidden.bs.toast', () => {
      toastElement.remove()
    })
  }
}
