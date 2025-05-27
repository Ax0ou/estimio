# app/controllers/quotes_controller.rb

class QuotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_quote, only: [:show, :edit, :update, :generate_from_ai]

  # GET /quotes
  def index
    @quotes = current_user.quotes
  end

  # GET /quotes/new
  def new
    @quote = current_user.quotes.new
    @quote.build_client
  end

  # POST /quotes
  def create
    @quote = current_user.quotes.build(quote_params)
    if @quote.save
      redirect_to  new_quote_ai_message_path(@quote), notice: "Quel est votre besoin ?"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /quotes/:id
  def show
    # @quote est chargé dans set_quote
  end

  # GET /quotes/:id/edit
  def edit
    # @quote est chargé dans set_quote
  end

  # PATCH/PUT /quotes/:id
  def update
    if @quote.update(quote_params)
      redirect_to quote_path(@quote), notice: "Devis mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # POST /quotes/:id/generate_from_ai
  def generate_from_ai
    prompt = <<~PROMPT
      À partir de ce texte : "#{@quote.content}"
      Génère-moi un devis au format JSON :
      {
        "title": "...",
        "project_type": "...",
        "items": [
          { "description": "...", "quantity": 1, "unit_price": 42.0 }
        ]
      }
    PROMPT

    chat    = RubyLLM.chat
    message = chat.ask(prompt)
    data    = JSON.parse(message.content) rescue {}

    @quote.update(
      title:        data["title"],
      project_type: data["project_type"]
    )

    @quote.quote_items.destroy_all
    Array(data["items"]).each do |i|
      @quote.quote_items.create!(
        description: i["description"],
        quantity:    i["quantity"],
        unit_price:  i["unit_price"]
      )
    end

    redirect_to edit_quote_path(@quote),
                notice: "Devis généré par l’IA, vous pouvez maintenant l’éditer."
  end

  private

  def set_quote
    @quote = current_user.quotes.find(params[:id])
  end

  def quote_params
    params.require(:quote).permit(
      :content, :title, :project_type,
      client_attributes: [:first_name, :last_name, :address, :phone_number]
    )
  end
end
