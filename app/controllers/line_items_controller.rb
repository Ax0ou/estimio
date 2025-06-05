class LineItemsController < ApplicationController
  def create
    @section = Section.find(params[:section_id])
    @quote = @section.quote
    @line_item = @section.line_items.new(line_item_params)
    if @line_item.save
      respond_to do |format|
        format.turbo_stream
      end
      # redirect_to edit_quote_path (@quote)
    # else
    #   render :new, status: :unprocessable_entity
    end
  end

  def edit
    @line_item = LineItem.find(params[:id])
  end

  def update
    @line_item = LineItem.find(params[:id])
    if @line_item.update(line_item_params)
      respond_to do |format|
        format.turbo_stream
      end
    # else
    #   render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @line_item = LineItem.find(params[:id])
    if @line_item.destroy
      respond_to do |format|
        format.turbo_stream
      end
    end
  end

  def reorder
    params[:order].each_with_index do |id, index|
      LineItem.where(id: id).update_all(position: index)
    end
    head :ok
  end

  private

  def line_item_params
    params.require(:line_item).permit(
      :description,
      :quantity,
      :unit_price,
      :price
    )
  end
end
