class QuotesController < ApplicationController
  def index
    @quotes = Quote.all
  end

  def show
    @quote = Quote.find(params[:id])
  end

  def new
    @quote = Quote.new
  end

  def create
    @quote = Quote.new(quote_params)
    @quote.user = current_user
    if @quote.save
      redirect_to  new_quote_ai_message_path(@quote)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def delete
    
  end

  private

  def quote_params
    params.require(:quote).permit(:title, :project_type, :client_id)
  end
end
