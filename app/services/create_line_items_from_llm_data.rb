class CreateLineItemsFromLlmData
  def initialize(llm_data, section:)
    @llm_data = llm_data
    @section = section
  end

  def call
    line_items = @llm_data.map do |item_data|
      LineItem.create!(
        section: @section,
        description: item_data["description"],
        quantity: item_data["quantity"],
        unit: item_data["unit"] || "u",
        price_per_unit: item_data["price_per_unit"]
      )
    end

    return line_items
  end
end
