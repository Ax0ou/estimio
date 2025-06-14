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
    # respond_to do |format|
    #   format.html
    #   format.pdf do
    #     render(
    #       pdf: "quote_#{@quote.id}"
    #     )
    #   end
    # end
  end

  def download_pdf
    @quote = Quote.find(params[:id])
    render(
      pdf: "quote_#{@quote.id}",
      template: 'quotes/pdf',
      layout: 'pdf'
    )
  end

  def new
    @company = current_user.company
    @quote = @company.quotes.new
  end

  def create
    @company = current_user.company
    @quote = @company.quotes.new(quote_params)

    if @quote.save
      flash_success("Devis créé avec succès.")
      redirect_to edit_quote_path(@quote)
    else
      flash_error("Erreur lors de la création du devis.")
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @quote = Quote.find(params[:id])
    @client = Client.find(@quote.client_id)  # Renommé pour cohérence
  end

  def update
    @quote = Quote.find(params[:id])
    if @quote.update(quote_params)
      flash_success("Devis mis à jour avec succès.")
      redirect_to quote_path(@quote)
    else
      flash_error("Erreur lors de la mise à jour du devis.")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @company = current_user.company
    @quote = @company.quotes.find(params[:id])
    if @quote.destroy
      flash_success("Devis supprimé avec succès.")
      redirect_to company_quotes_path(current_user.company)
    else
      flash_error("Une erreur est survenue lors de la suppression du devis.")
      redirect_to quote_path(@quote)
    end
  end

  def toggle_status
    @quote = current_user.company.quotes.find(params[:id])

    # Toggle entre les deux statuts
    new_status = @quote.a_traiter? ? :envoye : :a_traiter

    if @quote.update(status: new_status)
      flash_success("Statut mis à jour")
    else
      flash_error("Erreur")
    end

    redirect_to company_quotes_path
  end

  def add_section
    @quote = Quote.find(params[:id])
    @section = @quote.sections.create(description: params[:section][:description])

    if @section.persisted?
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_quote_path(@quote), notice: "Section ajoutée avec succès." }
      end
    else
      redirect_to edit_quote_path(@quote), alert: "Erreur lors de la création de la section."
    end
  end

  def update_legal_mentions
    @quote = Quote.find(params[:id])
    if @quote.update(legal_mentions_params)
      flash_success("Mentions légales mises à jour.")
      redirect_to quote_path(@quote)
    else
      flash_error("Erreur lors de la mise à jour des mentions légales.")
      redirect_to quote_path(@quote)
    end
  end

  private

  def quote_params
    params.require(:quote).permit(
      :title,
      :client_id,
      :project_type,  # Ajouté pour cohérence
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

  def legal_mentions_params
    params.require(:quote).permit(:validity_duration, :execution_delay, :payment_terms)
  end
end
