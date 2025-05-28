class QuotesController < ApplicationController
  before_action :set_quote, only: [:show, :destroy]

  def index
    @quotes = Quote.all
  end

  def show
  end

  def new
    @quote = Quote.new
  end

  def create
    @quote = Quote.new(quote_params)
    @quote.user = current_user
    if @quote.save
      redirect_to  new_quote_ai_message_path(@quote), notice: "Quel est votre besoin ?"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @quote.destroy
    redirect_to quotes_path, status: :see_other
  end

  private

  def set_quote
    @quote = Quote.find(params[:id])
  end

  def quote_params
    params.require(:quote).permit(:title, :project_type, :client_id)
  end
end
