class AiMessagesController < ApplicationController
  def new
    @quote = Quote.find(params[:quote_id])
    @ai_message = AiMessage.new
  end

  def create
    @quote = Quote.find(params[:quote_id])
    @ai_message = @quote.ai_messages.build(ai_message_params)
    @ai_message.prompt = "#{system_prompt}\n\nUser input: #{@ai_message.description}"

    if @ai_message.save
      # Appel de la gem RubyLLM avec le prompt utilisateur
      @chat = RubyLLM.chat
      @ai_message.update(content: @chat.with_instructions(system_prompt).ask(@ai_message.description).content)
      # Stocker la réponse dans le modèle
      redirect_to quote_path(@quote), notice: "Réponse IA enregistrée."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def ai_message_params
    params.require(:ai_message).permit(:description)
  end

  def system_prompt
    "You are a general contractor creating a detailed quote
    for an interior renovation project.
    Based on the client's input (voice description + photos), build a complete quote with:
    Tasks list (e.g., “Demolition of wall”, “Painting living room”
    “Installing new flooring”).
    For each task: Workforce: type, hours, rate, total. Materials: item name, quantity, price/unit excl. VAT, total.
    Add summary table and final total excl. VAT. and total time in days with 8 working hours per day Account for: Floor surface, ceiling height Room usage (bathroom, kitchen…)
    Waste evacuation, scaffolding, protection equipment Paint quality, flooring type, etc. Fill in missing info with
    reasonable expert estimates. Please return the answer in a very clear html format"
  end
end
