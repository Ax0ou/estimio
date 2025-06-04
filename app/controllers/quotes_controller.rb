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
      redirect_to edit_quote_path(@quote)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @quote = Quote.find(params[:id])
    client = Client.find(@quote.client_id)
  end

  def update
    @quote = Quote.find(params[:id])
    if @quote.update(quote_params)
      redirect_to quote_path(@quote), notice: "Devis mis à jour."
    else
      render :edit, status: :unprocessable_entity
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

  def add_section
    @quote = Quote.find(params[:id])
    @section = @quote.sections.create(description: params[:section][:description])
    @section.save
    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def quote_params
    params.require(:quote).permit(
    :title,
    :client_id,
    sections_attributes: [
      :id,
      :name,
      :_destroy,
      { line_items_attributes: %i[
        id
        name
        quantity
        unit_price
        total_price
        _destroy
      ] }
    ]
  )
  end
end
