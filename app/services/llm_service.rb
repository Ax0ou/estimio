class LlmService
  def initialize(transcript: nil)
    @description = transcript || section.description
  end

  def call
    prompt = system_prompt

    response = OpenAI::Client.new.chat(
      parameters: {
        model: "gpt-4",
        messages: [
          { role: "system", content: prompt },
          { role: "user", content: @description }
        ],
        temperature: 0.4
      }
    )

    content = response.dig("choices", 0, "message", "content")
    json = JSON.parse(content)
  end

  private

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
