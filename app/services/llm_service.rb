class LlmService
  def initialize(transcript: nil)
    @description = transcript || section.description
  end

  def extract_raw_json(content)
    content.gsub(/```json|```/, "").strip
  end

  def call

    chat = RubyLLM.chat
    chat.add_message(content: @description, role: "user")
    response = chat.with_instructions(system_prompt).ask(@description)

    clean_content = sanitize_llm_response(response.content)
    JSON.parse(clean_content)
    rescue JSON::ParserError => e
    Rails.logger.error("❌ Erreur de parsing JSON : #{e.message}")
    { error: 'Invalid JSON', raw: response.content }
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
    À partir d’une description textuelle, tu génères une liste de lignes de devis (line items) sous forme de tableau JSON.
    Les lignes doivent représenter la main d'oeuvvre mais aussi les matériaux nécessaires.

    ✅ Contexte
    - Il n’est **pas nécessaire de poser des questions supplémentaires**.
    - Il n’est **pas nécessaire de valider ou reformuler** la demande.
    - Ta seule mission est de proposer une première estimation sous forme structurée.
    - Ce résultat sera ensuite corrigé à la main par l’utilisateur dans l'interface.

    🧾 Format de réponse attendu :
    À partir de la description suivante "#{@description}", génère un JSON brut.
    Exemple attendu :
      Dans le json, Chaque élément du tableau (line item) doit contenir un champ section_id identique pour toutes les lignes, correspondant à l'identifiant unique de la section traitée.
      [
        {
          "description": "Pose de carrelage",
          "quantity": 2,
          "price_per_unit": 80
        },
        {
          "description": "Carrelage 60x60",
          "quantity": 20,
          "price_per_unit": 50,
        }
      ]

    PROMPT
  end

end
