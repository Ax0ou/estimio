class AiMessagesController < ApplicationController
  def new
    @quote = Quote.find(params[:quote_id])
    @ai_message = AiMessage.new
  end

  def create
    @quote = Quote.find(params[:quote_id])
    @ai_message = @quote.ai_messages.build(ai_message_params.merge(role: "user"))

    if @ai_message.save
      @chat = RubyLLM.chat
      build_conversation_history if @quote.ai_messages.count >= 2

      response = @chat.with_instructions(system_prompt).ask(@ai_message.description)
      AiMessage.create!(description: response.content, quote: @quote, role: "assistant")

      redirect_to quote_path(@quote)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def build_conversation_history
    @quote.ai_messages.each do |ai_message|
      @chat.add_message(content: ai_message.description, role: ai_message.role)
    end
  end

  def ai_message_params
    params.require(:ai_message).permit(:description)
  end

  def system_prompt
    "
      Tu es un expert en rénovation intérieure, spécialisé dans la création de devis détaillés.

      Tu connais parfaitement les prix des matériaux, les coûts de main-d'œuvre et les standards professionnels du secteur.
      Si l'utilisateur ne demande pas de devis, contente-toi de répondre à sa demande.
      Si l'utilisateur te demande un devis, tu dois d'abord t'assurer d'avoir toutes les informations nécessaires pour établir un devis de qualité.

      Si certaines données sont manquantes (par exemple : surface, hauteur sous plafond, usage des pièces, contraintes spécifiques…), pose des questions à l'utilisateur pour les obtenir.

      Lorsque tu as toutes les informations nécessaires, tu peux générer le devis.


      Il doit inclure:
        - Une liste des tâches (ex. : démolition, peinture, pose de sol…)
          Pour chaque tâche :
            - Main-d'œuvre : type, heures, tarif horaire, total
            - Matériaux : nom, quantité, prix unitaire HT, total

        Et à la fin un tableau récapitulatif : total HT et durée estimée en jours (8h/jour)

      Le format de la réponse est important, ce doit être une version imprimable en HTML bien structurée. Donc assure toi de ne pas ajouter de texte avant ou après le devis pour que ça s'affiche correctement.
    "
  end
end
