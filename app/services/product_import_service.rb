class ProductImportService
  SYSTEM_PROMPT = <<~PROMPT
    Tu es un assistant spécialisé dans l’analyse de devis dans le secteur du bâtiment.
    Je vais te fournir le contenu d’un devis sous forme de fichier pdf ou d'image.
    Ton objectif est d’en extraire la liste des produits ou prestations qui y figurent, et de les retranscrire dans un tableau JSON structuré comme suit :
    [
      {
        "name": "Nom du produit ou service",
        "price": montant en euros (entier ou décimal, sans symbole €),
        "unit": "unité parmi celles listées ci-dessous"
      }
    ]
    Les unités autorisées sont les suivantes (utilise exactement ces abréviations) :

    "u" : unité
    "m²" : mètre carré
    "h" : heure
    "kg" : kilogramme
    "m³" : mètre cube
    "j" : jour
    "g" : gramme
    "t" : tonne
    "l" : litre
    "m" : mètre

    Instructions supplémentaires :
      - Ne renvoie que le JSON final.
      - Si une donnée est absente ou incertaine, ignore la ligne.
      - Ne fais pas de commentaire ou d'explication.
      - Important: Le price_per_unit doit être en base de 1. Donc dans le devis il y a par exemple 3h pour 150€, le price_per_unit sera 50.
    PROMPT

  def self.call(files, company)
    files.each do |file|
      next if file.blank?

      response = RubyLLM.chat(model: 'google/gemini-2.5-flash-preview-05-20', provider: 'openrouter', assume_model_exists: true)
                        .with_instructions(SYSTEM_PROMPT)
                        .ask("Here is the file", with: { pdf: file.tempfile.path })
      clean_content = sanitize_llm_response(response.content)
      company.products.create(JSON.parse(clean_content))
    end
  rescue StandardError => e
    Rails.logger.error("Product import failed: #{e.message}")
    false
  end

  private

  def self.sanitize_llm_response(content)
    # Supprime les délimitations Markdown éventuelles comme ```json ou ```
    content.gsub(/```json|```/, "").strip
  end

end
