class QuotesController < ApplicationController
  before_action :set_quote, only: [:show, :edit, :update]

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
      redirect_to #path vers edit de la quote post GPT submit
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @quote.update(params[:quote])
  end

  private

  def set_quote
     @quote = Quote.find(params[:id])
  end

  def quote_params
    params.require(:quote).permit(:title, :project_type)
  end
end
