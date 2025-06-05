class LlmService
  def initialize(transcript: nil)
    @description = transcript || section.description
  end

  def extract_raw_json(content)
    content.gsub(/```json|```/, "").strip
  end

  def call
    prompt = system_prompt

    response = OpenAI::Client.new.chat(
      parameters: {
        model: "gpt-4o",
        messages: [
          { role: "system", content: prompt },
          { role: "user", content: @description }
        ],
        temperature: 0.4
      }
    )

    content = response.dig("choices", 0, "message", "content")
    clean_content = sanitize_llm_response(content)
    JSON.parse(clean_content)
  rescue JSON::ParserError => e
    Rails.logger.error("❌ Erreur de parsing JSON : #{e.message}")
    { error: 'Invalid JSON', raw: content }
  end

  private

  def sanitize_llm_response(content)
    # Supprime les délimitations Markdown éventuelles comme ```json ou ```
    content.gsub(/```json|```/, "").strip
  end

  def system_prompt
    <<~PROMPT
      🎯 Objectif
      Tu es un assistant IA francophone spécialisé dans le bâtiment.
      À partir d'une description textuelle, tu génères une liste de lignes de devis (line items) sous forme de tableau JSON.
      Les lignes doivent représenter la main d'oeuvre mais aussi les matériaux nécessaires.

      ✅ Contexte
      - Il n'est **pas nécessaire de poser des questions supplémentaires**.
      - Il n'est **pas nécessaire de valider ou reformuler** la demande.
      - Ta seule mission est de proposer une première estimation sous forme structurée.
      - Ce résultat sera ensuite corrigé à la main par l'utilisateur dans l'interface.

      🧾 Format de réponse attendu :
      À partir de la description suivante "#{@description}", génère un JSON brut.

      Chaque élément du tableau (line item) doit contenir :
      - description : description précise du travail/matériau
      - quantity : quantité estimée (nombre)
      - unit : unité appropriée ("u", "m²", "ml", "h", "m³", "kg")
      - price_per_unit : prix unitaire en euros

      Unités à utiliser :
      - "u" pour unités/pièces (équipements, appareils)
      - "m²" pour surfaces (carrelage, peinture, isolation)
      - "ml" pour longueurs (plinthes, tuyaux)
      - "h" pour heures de main-d'œuvre
      - "m³" pour volumes (béton, terre)
      - "kg" pour matériaux en vrac

      Exemple attendu :
      [
        {
          "description": "Pose de carrelage",
          "quantity": 20,
          "unit": "m²",
          "price_per_unit": 80
        },
        {
          "description": "Main d'œuvre pose",
          "quantity": 4,
          "unit": "h",
          "price_per_unit": 50
        }
      ]
    PROMPT
  end
end
