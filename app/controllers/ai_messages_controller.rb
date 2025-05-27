class AiMessagesController < ApplicationController
  def new
    @quote = Quote.find(params[:quote_id])
    @ai_message = AiMessage.new
  end

  def create
    @quote = Quote.find(params[:quote_id])
    @ai_message = @quote.ai_messages.build(ai_message_params)

    if @ai_message.save
      # Appel de la gem RubyLLM avec le prompt utilisateur
      response = RubyLLM.chat(prompt: @ai_message.prompt)

      # Stocker la réponse dans le modèle
      @ai_message.update(ai_response: response.completion)

      redirect_to quote_path(@quote), notice: "Réponse IA enregistrée."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def ai_message_params
    params.require(:ai_message).permit(:description, :prompt)
  end
end
