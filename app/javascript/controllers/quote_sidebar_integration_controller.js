// app/javascript/controllers/quote_sidebar_integration_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["totalContainer"]
  static values = {
    quoteId: String,
    updateUrl: String
  }

  connect() {
    console.log("Quote sidebar integration connected")
    this.setupTurboStreamHandlers()
    this.initializeRealtimeUpdates()
  }

  disconnect() {
    this.teardownRealtimeUpdates()
  }

  // Configuration des handlers Turbo Stream
  setupTurboStreamHandlers() {
    // Écouter les mises à jour de totaux
    document.addEventListener('turbo:before-stream-render', this.handleTotalUpdates.bind(this))

    // Écouter les ajouts de sections/line items
    document.addEventListener('turbo:frame-render', this.handleContentChanges.bind(this))
  }

  // Gestion des mises à jour de totaux en temps réel
  handleTotalUpdates(event) {
    if (event.target.id === 'quote-total') {
      this.animateTotal()
      this.updateSectionTotals()
    }
  }

  // Gestion des changements de contenu
  handleContentChanges(event) {
    // Mettre à jour les options du select de sections dans la sidebar
    if (event.target.matches('[data-turbo-frame]')) {
      this.refreshSectionOptions()
    }
  }

  // Animation du total lors des mises à jour
  animateTotal() {
    const totalElement = this.element.querySelector('#quote-total')
    if (totalElement) {
      totalElement.style.transform = 'scale(1.05)'
      totalElement.style.transition = 'transform 0.2s ease'

      setTimeout(() => {
        totalElement.style.transform = 'scale(1)'
      }, 200)
    }
  }

  // Mise à jour des totaux par section
  updateSectionTotals() {
    const sectionTotalsContainer = this.element.querySelector('.section-totals')
    if (!sectionTotalsContainer) return

    // Récupérer les nouveaux totaux via fetch si nécessaire
    fetch(`/quotes/${this.quoteIdValue}/section_totals`, {
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.json())
    .then(data => {
      this.renderSectionTotals(data.sections)
    })
    .catch(error => console.error('Erreur lors de la mise à jour des totaux:', error))
  }

  // Rendu des totaux par section
  renderSectionTotals(sections) {
    const container = this.element.querySelector('.section-totals')
    if (!container) return

    container.innerHTML = sections.map(section => `
      <div class="d-flex justify-content-between py-1 small">
        <span class="text-truncate me-2"
              title="${section.description}"
              data-bs-toggle="tooltip"
              data-bs-placement="top">
          ${this.truncateText(section.description, 25)}
        </span>
        <span class="fw-semibold">
          ${this.formatCurrency(section.total_ht)}
        </span>
      </div>
    `).join('')

    // Réinitialiser les tooltips
    this.initializeTooltips(container)
  }

  // Actualiser les options du select de sections
  refreshSectionOptions() {
    const sectionSelect = this.element.querySelector('[data-sidebar-target="sectionSelect"]')
    if (!sectionSelect) return

    fetch(`/quotes/${this.quoteIdValue}/sections`, {
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.json())
    .then(data => {
      const currentValue = sectionSelect.value

      sectionSelect.innerHTML = '<option value="">Choisir une section...</option>' +
        data.sections.map(section =>
          `<option value="${section.id}" ${section.id == currentValue ? 'selected' : ''}>
            ${this.truncateText(section.description, 30)}
          </option>`
        ).join('')
    })
    .catch(error => console.error('Erreur lors de la mise à jour des sections:', error))
  }

  // Initialisation des mises à jour temps réel
  initializeRealtimeUpdates() {
    // Polling léger pour synchroniser les totaux (si pas de WebSocket)
    this.updateInterval = setInterval(() => {
      this.syncTotals()
    }, 30000) // Toutes les 30 secondes
  }

  // Nettoyage des mises à jour temps réel
  teardownRealtimeUpdates() {
    if (this.updateInterval) {
      clearInterval(this.updateInterval)
    }
  }

  // Synchronisation des totaux
  async syncTotals() {
    try {
      const response = await fetch(`/quotes/${this.quoteIdValue}/totals`, {
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })

      if (response.ok) {
        const data = await response.json()
        this.updateTotalDisplay(data)
      }
    } catch (error) {
      console.error('Erreur de synchronisation:', error)
    }
  }

  // Mise à jour de l'affichage des totaux
  updateTotalDisplay(data) {
    const totalHT = this.element.querySelector('.text-primary .h6')
    const totalTTC = this.element.querySelector('.text-success .h5')
    const tva = this.element.querySelector('small .fw-semibold')

    if (totalHT) totalHT.textContent = this.formatCurrency(data.total_ht)
    if (totalTTC) totalTTC.textContent = this.formatCurrency(data.total_ttc)
    if (tva) tva.textContent = this.formatCurrency(data.total_ttc - data.total_ht)
  }

  // Utilitaires

  truncateText(text, length) {
    return text.length > length ? text.substring(0, length) + '...' : text
  }

  formatCurrency(amount) {
    return new Intl.NumberFormat('fr-FR', {
      style: 'currency',
      currency: 'EUR',
      minimumFractionDigits: 2
    }).format(amount)
  }

  initializeTooltips(container = this.element) {
    const tooltipTriggerList = container.querySelectorAll('[data-bs-toggle="tooltip"]')
    const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl =>
      new bootstrap.Tooltip(tooltipTriggerEl)
    )
  }

  // Méthodes publiques pour l'intégration avec d'autres contrôleurs

  // Notification d'ajout de section
  onSectionAdded(sectionData) {
    this.refreshSectionOptions()
    this.updateSectionTotals()
    this.showNotification('Section ajoutée avec succès', 'success')
  }

  // Notification de mise à jour de line item
  onLineItemUpdated(lineItemData) {
    this.updateSectionTotals()
    this.animateTotal()
  }

  // Notification d'erreur
  onError(message) {
    this.showNotification(message, 'error')
  }

  // Système de notifications
  showNotification(message, type = 'info') {
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
