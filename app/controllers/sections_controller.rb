class SectionsController < ApplicationController
  def add_line_items_with_llm
    # binding.pry
    @section = Section.find(params[:id])
    llm_data = LlmService.new(transcript: params[:transcript][:text]).call
    CreateLineItemsFromLlmData.new(llm_data, section: @section).call
    redirect_to edit_quote_path(@section.quote), notice: "Ligne(s) ajoutée(s) avec succès."
  end
end
