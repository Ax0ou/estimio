class CreateLneItemsFromLLMData
  def initialize(llm_data)
    @llm_data = llm_data
  end

  def call
    line_items = @llm_data.map do |item_data|
      LineItem.create!(
        section_id: item_data[:section_id],
        description: item_data[:description],
        quantity: item_data[:quantity],
        price_per_unit: item_data[:price_per_unit]
      )
    end

    return line_items
  end
end
