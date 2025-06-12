// Testeur de fonctionnalités sidebar - À exécuter dans la console du navigateur
// Copiez-collez ce code dans la console pour tester les fonctionnalités

console.log("🧪 Test des fonctionnalités de la sidebar");

// Test 1: Vérification de la présence du contrôleur Stimulus
const sidebarElement = document.querySelector('[data-controller="sidebar"]');
if (sidebarElement) {
  console.log("✅ Contrôleur Stimulus détecté");

  // Test 2: Vérification des targets
  const targets = [
    'sectionSelect', 'description', 'analyzeButton',
    'recordButton', 'statusIndicator', 'aiNotes'
  ];

  targets.forEach(target => {
    const element = sidebarElement.querySelector(`[data-sidebar-target="${target}"]`);
    if (element) {
      console.log(`✅ Target "${target}" trouvé`);
    } else {
      console.log(`❌ Target "${target}" manquant`);
    }
  });

} else {
  console.log("❌ Contrôleur Stimulus non trouvé");
}

// Test 3: Vérification des styles CSS
const testStyles = () => {
  const sidebar = document.querySelector('.sidebar-sticky');
  if (sidebar) {
    const styles = window.getComputedStyle(sidebar);
    console.log("📊 Styles de la sidebar:");
    console.log(`- Position: ${styles.position}`);
    console.log(`- Top: ${styles.top}`);
    console.log(`- Overflow-Y: ${styles.overflowY}`);

    // Test de la scrollbar
    const scrollbarWidth = sidebar.offsetWidth - sidebar.clientWidth;
    console.log(`- Largeur scrollbar: ${scrollbarWidth}px`);
  }
};

// Test 4: Simulation d'interactions
const testInteractions = () => {
  console.log("🔧 Test des interactions...");

  // Test du select de section
  const sectionSelect = document.querySelector('[data-sidebar-target="sectionSelect"]');
  if (sectionSelect && sectionSelect.options.length > 1) {
    console.log("✅ Select de sections fonctionnel");

    // Simuler une sélection
    sectionSelect.selectedIndex = 1;
    sectionSelect.dispatchEvent(new Event('change'));
    console.log("📋 Sélection de section simulée");
  }

  // Test du textarea
  const description = document.querySelector('[data-sidebar-target="description"]');
  if (description) {
    description.value = "Test d'analyse IA: pose de carrelage 10m²";
    description.dispatchEvent(new Event('input'));
    console.log("📝 Saisie de description simulée");
  }

  // Test du bouton d'analyse
  const analyzeButton = document.querySelector('[data-sidebar-target="analyzeButton"]');
  if (analyzeButton) {
    console.log(`🔍 Bouton d'analyse: ${analyzeButton.disabled ? 'désactivé' : 'activé'}`);
  }
};

// Test 5: Vérification responsive
const testResponsive = () => {
  console.log("📱 Test responsive...");
  const sidebar = document.querySelector('.sidebar-sticky');
  const mainContent = document.querySelector('.col-lg-8');

  if (sidebar && mainContent) {
    const sidebarRect = sidebar.getBoundingClientRect();
    const mainRect = mainContent.getBoundingClientRect();

    console.log(`📏 Largeur sidebar: ${Math.round(sidebarRect.width)}px`);
    console.log(`📏 Largeur contenu principal: ${Math.round(mainRect.width)}px`);

    // Test du breakpoint
    if (window.innerWidth < 992) {
      console.log("📱 Mode tablette/mobile détecté");
    } else {
      console.log("💻 Mode desktop détecté");
    }
  }
};

// Test 6: Vérification des couleurs
const testColors = () => {
  console.log("🎨 Test des couleurs...");

  const totalsHeader = document.querySelector('.card-header.totals-header');
  const aiHeader = document.querySelector('.card-header.ai-header');

  if (totalsHeader) {
    const bgColor = window.getComputedStyle(totalsHeader).backgroundColor;
    console.log(`🔵 Couleur header Totaux: ${bgColor}`);
  }

  if (aiHeader) {
    const bgColor = window.getComputedStyle(aiHeader).backgroundColor;
    console.log(`🟢 Couleur header IA: ${bgColor}`);
  }
};

// Exécution des tests
setTimeout(() => {
  testStyles();
  testInteractions();
  testResponsive();
  testColors();
  console.log("🎉 Tests terminés ! Vérifiez les résultats ci-dessus.");
}, 500);

// Fonction utilitaire pour tester l'API
window.testSidebarAPI = async () => {
  console.log("🌐 Test des APIs...");

  const quoteId = document.querySelector('[data-sidebar-quote-id-value]')?.dataset.sidebarQuoteIdValue;

  if (quoteId) {
    try {
      // Test API totaux
      const totalsResponse = await fetch(`/quotes/${quoteId}/totals`);
      if (totalsResponse.ok) {
        const data = await totalsResponse.json();
        console.log("✅ API totaux fonctionnelle:", data);
      }

      // Test API sections
      const sectionsResponse = await fetch(`/quotes/${quoteId}/sections`);
      if (sectionsResponse.ok) {
        const data = await sectionsResponse.json();
        console.log("✅ API sections fonctionnelle:", data);
      }

    } catch (error) {
      console.log("❌ Erreur API:", error.message);
    }
  }
};

console.log("💡 Tapez 'testSidebarAPI()' pour tester les APIs");
