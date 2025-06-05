class AddUnitToLineItems < ActiveRecord::Migration[7.1]
  def change
    add_column :line_items, :unit, :string, default: "u"
  end
end
