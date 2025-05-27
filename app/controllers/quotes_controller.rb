class QuotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_quote, only: [:show, :edit, :update, :generate_from_ai]

  def index
    @quotes = current_user.quotes
  end

  def new
    @quote = current_user.quotes.new
  end

  def create
    @quote = current_user.quotes.build(quote_params)
    if @quote.save
      redirect_to edit_quote_path(@quote), notice: "Devis créé, vous pouvez maintenant le générer via l’IA."
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @quote.update(quote_params)
      redirect_to quote_path(@quote), notice: "Devis mis à jour."
    else
      render :edit
    end
  end

  def generate_from_ai
    prompt = <<~PROMPT
      À partir de ce texte : "#{@quote.content}"
      Génère-moi un devis au format JSON :
      {
        "title": "...",
        "project_type": "...",
        "items": [
          { "description": "...", "quantity": 1, "unit_price": 42.0 },
          …
        ]
      }
    PROMPT

    response = RubyLLM.chat(prompt: prompt)
    data     = JSON.parse(response.completion) rescue {}

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

    redirect_to edit_quote_path(@quote), notice: "Devis généré par l’IA, vous pouvez maintenant l’éditer."
  end

  private

  def set_quote
    @quote = current_user.quotes.find(params[:id])
  end

  def quote_params
    params.require(:quote).permit(:content, :title, :project_type, :client_id)
  end
end
