class QuotesController < ApplicationController
  def index
    company = current_user.company
    @quotes = company.quotes
    @quotes = @quotes.where(project_type: params[:project_type]) if params[:project_type].present? && params[:project_type] != "Tous"
    @quotes = @quotes.where("DATE(created_at) = ?", params[:date]) if params[:date].present?
    @quotes = @quotes.where("title ILIKE ?", "%#{params[:title]}%") if params[:title].present?
  end

  def show
    @quote = Quote.find(params[:id])
  end

  def new
    @company = current_user.company
    @quote = @company.quotes.new
  end

  def create
    @company = current_user.company
    @quote = @company.quotes.new(quote_params)

    if @quote.save
      redirect_to  quote_path(@quote)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @company = current_user.company
    @quote = @company.quotes.find(params[:id])
    if @quote.destroy
      redirect_to company_quotes_path(@company), notice: "Devis supprimé avec succès."
    else
      redirect_to quote_path(@quote), alert: "Une erreur est survenue lors de la suppression du devis."
    end
  end

  private

  def quote_params
    params.require(:quote).permit(:title, :project_type, :client_id)
  end
end
