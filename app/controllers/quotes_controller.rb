class QuotesController < ApplicationController
  def index
    @quotes = Quote.find(params[:user_id])
  end

  def show
    @quote = Quote.find(params[:user_id][:id])
  end

  def new
    @quote = Quote.new
  end

  def create
    @quote = Quote.new(quote_params)
    @user = User.find(:user_id)
    @quote.user = @user
    if @quote.save
      redirect_to #path vers edit de la quote post GPT submit
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @quote = Quote.find(params[:user_id][:id])
  end

  def update
    @quote = Quote.find(params[:user_id][:id])
    @quote.update(params[:quote])
  end

  private

  def quote_params
    params.require(:quote).permit(:title, :project_type)
  end
end
