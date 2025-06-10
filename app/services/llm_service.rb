class LlmService
  def initialize(transcript: nil)
    @description = transcript || section.description
  end

  def extract_raw_json(content)
    content.gsub(/```json|```/, "").strip
  end

  def call

    chat = RubyLLM.chat(model: 'google/gemini-2.5-flash-preview-05-20', provider: 'openrouter', assume_model_exists: true)
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
      "u"     => "unité",
      "m²"    => "mètre carré",
      "h"     => "heure",
      "kg"    => "kilogramme",
      "m³"    => "mètre cube",
      "j"     => "jour",
      "g"     => "gramme",
      "t"     => "tonne",
      "l"     => "litre",
      "m"     => "mètre"

      Dans un premier temps, consulte la base de données de produits de l'artisan pour récupérer les prix unitaires des matériaux et services courants.
      Voici la liste #{Product.pluck(:name, :price, :unit).map { |name, price, unit| "#{name} (#{price} €/#{unit})" }.join(', ')}

      Exemple attendu :
      🧾 Format de réponse attendu :
      À partir de la description suivante "#{@description}", génère un JSON brut.
      Exemple attendu, il faut absolument qu'il y ait ces trois éléments, quantity et price_per_unit ainsi que la description. Assure-toi qu'il y ait une bonne logique de quantité entre si c'est des matériaux ou si c'est des heures.
        Dans le json, Chaque élément du tableau (line item) doit contenir un champ section_id identique pour toutes les lignes, correspondant à l'identifiant unique de la section traitée.
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
