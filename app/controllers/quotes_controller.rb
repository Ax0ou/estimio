class QuotesController < ApplicationController
  def index
    @quotes = Quote.all
    @quotes = @quotes.where(project_type: params[:project_type]) if params[:project_type].present? && params[:project_type] != "Tous"
    @quotes = @quotes.where("DATE(created_at) = ?", params[:date]) if params[:date].present?
    @quotes = @quotes.where("title ILIKE ?", "%#{params[:title]}%") if params[:title].present?
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
      redirect_to  quote_path(@quote)
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
