// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap"

// import "bootstrap"


// import "controllers/audio_recorder_controller"

// document.addEventListener("turbo:load", setupAudioRecorder);
// document.addEventListener("DOMContentLoaded", setupAudioRecorder);

// function setupAudioRecorder() {
//   let mediaRecorder, audioChunks = [];
//   let isRecording = false;

//   const startBtn = document.getElementById("start-record");
//   const status = document.getElementById("recording-status");
//   const descriptionField = document.getElementById("ai_message_description");
//   const audioPreview = document.getElementById("audio-preview");

//   if (startBtn && descriptionField) {
//     startBtn.onclick = async () => {
//       if (isRecording) {
//         // Arrêter l'enregistrement
//         mediaRecorder.stop();
//         mediaRecorder.stream.getTracks().forEach(track => track.stop());
//         isRecording = false;
//         status.style.display = "none";
//         startBtn.innerHTML = '<i class="bi bi-mic-fill me-2"></i><span>Enregistrer audio</span>';
//         startBtn.classList.remove("btn-danger");
//         startBtn.classList.add("btn-outline-primary");
//         return;
//       }

//       if (!navigator.mediaDevices) {
//         alert("L'enregistrement audio n'est pas supporté par ce navigateur.");
//         return;
//       }

//       // Démarrer l'enregistrement
//       audioChunks = [];
//       const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
//       mediaRecorder = new MediaRecorder(stream);
//       mediaRecorder.stream = stream;

//       mediaRecorder.ondataavailable = e => audioChunks.push(e.data);
//       mediaRecorder.onstop = async () => {
//         const audioBlob = new Blob(audioChunks, { type: "audio/webm" });
//         // Affiche le lecteur audio avec l'enregistrement
//         if (audioPreview) {
//           const audioUrl = URL.createObjectURL(audioBlob);
//           audioPreview.src = audioUrl;
//           audioPreview.style.display = "block";
//           audioPreview.load();
//         }
//         // Envoie l'audio à Whisper
//         const formData = new FormData();
//         formData.append("audio", audioBlob, "audio.webm");
//         try {
//           const response = await fetch("/speech_to_text", {
//             method: "POST",
//             body: formData,
//             headers: { "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content }
//           });
//           const data = await response.json();
//           if (data.text) {
//             descriptionField.value = data.text;
//           } else {
//             alert("Erreur lors de la transcription.");
//           }
//         } catch (error) {
//           alert("Erreur de connexion lors de la transcription.");
//         }
//       };

//       mediaRecorder.start();
//       isRecording = true;
//       status.style.display = "inline";
//       startBtn.innerHTML = '<i class="bi bi-stop-fill me-2"></i><span>Arrêter</span>';
//       startBtn.classList.add("btn-danger");
//       startBtn.classList.remove("btn-outline-primary");
//     };
//   }
// }

// Global modal backdrop cleanup for Turbo navigation
function cleanupModalBackdrops() {
  // Remove all modal backdrops
  const backdrops = document.querySelectorAll('.modal-backdrop');
  backdrops.forEach(backdrop => backdrop.remove());

  // Reset body classes and styles
  document.body.classList.remove('modal-open');
  document.body.style.overflow = '';
  document.body.style.paddingRight = '';
  document.body.style.marginRight = '';
}

// Clean up on page load
document.addEventListener('DOMContentLoaded', cleanupModalBackdrops);

// Clean up before Turbo navigation
document.addEventListener('turbo:before-visit', cleanupModalBackdrops);

// Clean up after Turbo navigation
document.addEventListener('turbo:load', cleanupModalBackdrops);

// Clean up on page unload
window.addEventListener('beforeunload', cleanupModalBackdrops);
