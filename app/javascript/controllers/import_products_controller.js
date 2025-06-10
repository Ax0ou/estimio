import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submitButton", "loadingOverlay", "dropZone", "fileInput", "fileList"]

  connect() {
    this.element.addEventListener("submit", this.handleSubmit.bind(this))
  }

  triggerFileInput() {
    this.fileInputTarget.click()
  }

  handleDragOver(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dropZoneTarget.classList.add("border-primary")
  }

  handleDragEnter(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dropZoneTarget.classList.add("border-primary")
  }

  handleDragLeave(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dropZoneTarget.classList.remove("border-primary")
  }

  handleDrop(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dropZoneTarget.classList.remove("border-primary")

    const files = event.dataTransfer.files
    this.fileInputTarget.files = files
    this.handleFiles()
  }

  handleFiles() {
    const files = this.fileInputTarget.files
    this.updateFileList(files)
    this.updateSubmitButton()
  }

  getFileIcon(file) {
    const extension = file.name.split('.').pop().toLowerCase()
    const imageExtensions = ['jpg', 'jpeg', 'png']

    if (imageExtensions.includes(extension)) {
      return 'bi-image'
    } else if (extension === 'pdf') {
      return 'bi-file-earmark-pdf'
    } else if (['doc', 'docx'].includes(extension)) {
      return 'bi-file-earmark-word'
    }
    return 'bi-file-earmark'
  }

  isImageFile(file) {
    const extension = file.name.split('.').pop().toLowerCase()
    return ['jpg', 'jpeg', 'png', 'gif'].includes(extension)
  }

  updateFileList(files) {
    this.fileListTarget.innerHTML = ""

    if (files.length === 0) return

    const fileList = document.createElement("div")
    fileList.className = "list-group"

    Array.from(files).forEach(file => {
      const fileItem = document.createElement("div")
      fileItem.className = "list-group-item d-flex justify-content-between align-items-center"

      const fileInfo = document.createElement("div")
      fileInfo.className = "d-flex align-items-center"

      if (this.isImageFile(file)) {
        const preview = document.createElement("div")
        preview.className = "me-3"
        preview.style.width = "40px"
        preview.style.height = "40px"
        preview.style.overflow = "hidden"
        preview.style.borderRadius = "4px"

        const img = document.createElement("img")
        img.style.width = "100%"
        img.style.height = "100%"
        img.style.objectFit = "cover"

        const reader = new FileReader()
        reader.onload = (e) => {
          img.src = e.target.result
        }
        reader.readAsDataURL(file)

        preview.appendChild(img)
        fileInfo.appendChild(preview)
      } else {
        const icon = document.createElement("i")
        icon.className = `bi ${this.getFileIcon(file)} text-primary me-2`
        fileInfo.appendChild(icon)
      }

      const fileName = document.createElement("span")
      fileName.textContent = file.name

      const fileSize = document.createElement("small")
      fileSize.className = "text-muted ms-2"
      fileSize.textContent = this.formatFileSize(file.size)

      fileInfo.appendChild(fileName)
      fileInfo.appendChild(fileSize)

      const removeButton = document.createElement("button")
      removeButton.className = "btn btn-sm btn-outline-danger"
      removeButton.innerHTML = '<i class="bi bi-x"></i>'
      removeButton.onclick = (e) => {
        e.preventDefault()
        this.removeFile(file)
      }

      fileItem.appendChild(fileInfo)
      fileItem.appendChild(removeButton)
      fileList.appendChild(fileItem)
    })

    this.fileListTarget.appendChild(fileList)
  }

  removeFile(fileToRemove) {
    const dt = new DataTransfer()
    const files = this.fileInputTarget.files

    Array.from(files).forEach(file => {
      if (file !== fileToRemove) {
        dt.items.add(file)
      }
    })

    this.fileInputTarget.files = dt.files
    this.handleFiles()
  }

  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }

  updateSubmitButton() {
    this.submitButtonTarget.disabled = this.fileInputTarget.files.length === 0
  }

  handleSubmit(event) {
    this.submitButtonTarget.disabled = true
    this.loadingOverlayTarget.classList.remove("d-none")
  }
}
