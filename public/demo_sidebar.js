// Script de démonstration des fonctionnalités sidebar
// À copier-coller dans la console du navigateur pour tester

console.log("🎯 DÉMONSTRATION SIDEBAR ESTIM.IO");
console.log("=================================");

// Test 1: Vérification du contrôleur
const sidebarElement = document.querySelector('[data-controller*="ai-assistant"]');
if (sidebarElement) {
  console.log("✅ Contrôleur AI Assistant trouvé");

  // Test 2: Vérification des targets
  const targets = ["sectionSelect", "description", "analyzeBtn", "recordBtn"];
  targets.forEach(target => {
    const element = sidebarElement.querySelector(`[data-ai-assistant-target="${target}"]`);
    if (element) {
      console.log(`✅ Target "${target}" présent`);
    } else {
      console.log(`❌ Target "${target}" manquant`);
    }
  });

  // Test 3: Simulation d'interaction
  const sectionSelect = sidebarElement.querySelector('[data-ai-assistant-target="sectionSelect"]');
  const description = sidebarElement.querySelector('[data-ai-assistant-target="description"]');

  if (sectionSelect && description) {
    console.log("🧪 Simulation d'une interaction complète...");

    // Simuler sélection de section
    if (sectionSelect.options.length > 1) {
      sectionSelect.selectedIndex = 1;
      sectionSelect.dispatchEvent(new Event('change'));
      console.log("✅ Section sélectionnée automatiquement");
    }

    // Simuler saisie de texte
    description.value = "Pose de carrelage dans une salle de bain de 8m²";
    description.dispatchEvent(new Event('input'));
    console.log("✅ Description saisie automatiquement");

    // Vérifier l'état du bouton d'analyse
    const analyzeBtn = sidebarElement.querySelector('[data-ai-assistant-target="analyzeBtn"]');
    if (analyzeBtn && !analyzeBtn.disabled) {
      console.log("✅ Bouton d'analyse activé correctement");
    }
  }

} else {
  console.log("❌ Contrôleur AI Assistant non trouvé");
}

// Test 4: Vérification des styles CSS
console.log("\n🎨 Vérification des styles...");
const sidebar = document.querySelector('.sidebar-container');
if (sidebar) {
  const styles = getComputedStyle(sidebar);
  console.log(`📍 Position: ${styles.position}`);
  console.log(`📏 Top: ${styles.top}`);
  console.log(`📜 Overflow-Y: ${styles.overflowY}`);
} else {
  console.log("❌ Container sidebar non trouvé");
}

// Test 5: Fonctions globales
console.log("\n🔧 Vérification des fonctions globales...");
if (typeof window.selectSection === 'function') {
  console.log("✅ Function selectSection disponible");
} else {
  console.log("❌ Function selectSection manquante");
}

if (typeof window.analyzeDescription === 'function') {
  console.log("✅ Function analyzeDescription disponible");
} else {
  console.log("❌ Function analyzeDescription manquante");
}

console.log("\n🚀 La sidebar est prête ! Tests terminés.");
console.log("💡 Vous pouvez maintenant interagir avec l'interface.");
