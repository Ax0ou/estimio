<!--
  ===================================================
  GUIDE D'UTILISATION DE LA SIDEBAR AMÉLIORRÉE
  ===================================================

  Cette nouvelle structure de sidebar a été conçue pour être :
  ✅ Perfectly sticky/fixed selon les besoins
  ✅ Responsive (ordinateur + tablette)
  ✅ Extensible facilement
  ✅ Bien espacée et lisible
  ✅ Compatible avec votre système Rails + Bootstrap 5

  📐 STRUCTURE ACTUELLE :

  1. **Bloc Totaux** (card bg-primary)
     - Affichage des totaux HT/TTC en temps réel
     - Détail par section avec noms tronqués
     - Calculs automatiques TVA

  2. **Bloc Assistant IA** (card bg-success)
     - Sélection de section
     - Textarea pour description (reste large pour lisibilité)
     - Bouton d'analyse connecté au contrôleur Stimulus
     - Options avancées collapsibles (vocal, notes IA)

  3. **Section extensible** (pour futurs ajouts)
     - Template prêt à être déplié
     - Système de couleurs cohérent

  🔧 COMMENT AJOUTER UNE NOUVELLE SECTION :

  1. **Dupliquer le bloc template** :
     ```erb
     <div class="card shadow-sm border-0 mb-3">
       <div class="card-header bg-info text-white py-3">
         <h5 class="mb-0 d-flex align-items-center">
           <i class="bi bi-VOTRE-ICONE me-2"></i>
           Nom de votre section
         </h5>
       </div>
       <div class="card-body">
         <!-- Votre contenu ici -->
       </div>
     </div>
     ```

  2. **Couleurs disponibles pour les headers** :
     - bg-primary (bleu) - pour les calculs/totaux
     - bg-success (vert) - pour l'IA/automatisation
     - bg-info (cyan) - pour les informations/stats
     - bg-warning (orange) - pour les alertes/rappels
     - bg-danger (rouge) - pour les erreurs/validations
     - bg-secondary (gris) - pour les utilitaires

  3. **Icônes Bootstrap disponibles** :
     - bi-calculator (calculatrice)
     - bi-robot (IA)
     - bi-mic-fill (audio)
     - bi-gear (réglages)
     - bi-clock-history (historique)
     - bi-chart-bar (statistiques)
     - bi-bell (notifications)
     - bi-file-text (documents)
     - bi-cloud-upload (import/export)

  📱 RESPONSIVE :

  - **Desktop (>992px)** : Sidebar sticky à droite (col-lg-4 col-xl-3)
  - **Tablette (768-991px)** : Sidebar passe au-dessus, order: -1
  - **Mobile (<768px)** : Stack vertical complet

  🎨 PERSONNALISATION CSS :

  Les styles sont dans `app/assets/stylesheets/quotes.scss` :
  - Variables de couleurs en haut du fichier
  - Section `.sidebar-sticky` pour les styles généraux
  - Section responsive avec @media queries
  - Animations et transitions configurables

  🔌 INTÉGRATION STIMULUS :

  Deux contrôleurs disponibles :
  1. `sidebar_controller.js` - Gestion des interactions dans la sidebar
  2. `quote_sidebar_integration_controller.js` - Intégration avec le système Rails

  📋 EXEMPLE D'AJOUT D'UNE SECTION "STATISTIQUES" :

  ```erb
  <!-- Section Statistiques -->
  <div class="card shadow-sm border-0 mb-3">
    <div class="card-header bg-info text-white py-3">
      <h5 class="mb-0 d-flex align-items-center">
        <i class="bi bi-chart-bar me-2"></i>
        Statistiques
      </h5>
    </div>
    <div class="card-body">
      <div class="row text-center g-2">
        <div class="col-6">
          <div class="fw-bold text-info h6 mb-1">
            <%= @quote.sections.count %>
          </div>
          <small class="text-muted">Sections</small>
        </div>
        <div class="col-6">
          <div class="fw-bold text-info h6 mb-1">
            <%= @quote.sections.joins(:line_items).count %>
          </div>
          <small class="text-muted">Éléments</small>
        </div>
      </div>

      <div class="mt-3 pt-3 border-top">
        <small class="text-muted fw-semibold d-block mb-2">Progression</small>
        <div class="progress" style="height: 8px;">
          <div class="progress-bar bg-info" style="width: 65%"></div>
        </div>
        <small class="text-muted">65% complété</small>
      </div>

      <button type="button" class="btn btn-outline-info btn-sm w-100 mt-3">
        <i class="bi bi-download me-1"></i>
        Exporter les stats
      </button>
    </div>
  </div>
  ```

  🚀 BONNES PRATIQUES :

  - Toujours utiliser des classes Bootstrap pour la cohérence
  - Préfixer vos IDs/classes custom avec votre nom de section
  - Tester sur différentes tailles d'écran
  - Utiliser `truncate()` pour les textes longs
  - Ajouter des tooltips pour les éléments tronqués
  - Intégrer avec Stimulus pour les interactions complexes

  💡 ASTUCES :

  - Le champ Description des line items garde sa largeur (contrainte respectée)
  - Les labels longs sont automatiquement abrégés avec des tooltips
  - La sidebar scrolle indépendamment du contenu principal
  - Animations CSS configurables dans le fichier SCSS
  - Support du dark mode prêt (media query prefers-color-scheme)

  ===================================================
-->
