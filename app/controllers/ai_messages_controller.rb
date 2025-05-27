# app/controllers/ai_messages_controller.rb

class AiMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_quote

  def new
    @ai_message = @quote.ai_messages.new
  end

  def create
    @ai_message = @quote.ai_messages.build(ai_message_params)
    if @ai_message.save
      response = RubyLLM.chat.ask(prompt: @ai_message.prompt)
      @ai_message.update(ai_response: response.content)
      redirect_to quote_path(@quote), notice: "Réponse IA enregistrée."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_quote
    @quote = current_user.quotes.find(params[:quote_id])
  end

  def ai_message_params
    params.require(:ai_message).permit(:description, :prompt)
  end
end
