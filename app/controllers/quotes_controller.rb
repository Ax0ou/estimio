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

  def edit
    @quote = Quote.includes(section: :line_items).find(params[:id])
  end

  def update
    @quote = Quote.find(params[:id])
    if @quote.update(quote_params)
      redirect_to quote_path(@quote), notice: "Devis mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def delete
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
