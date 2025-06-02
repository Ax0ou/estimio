class CreateLineItems < ActiveRecord::Migration[7.1]
  def change
    create_table :line_items do |t|
      t.references :section, null: false, foreign_key: true # Reference to the quote this line item belongs to
      t.string :description # Description of the line item
      t.integer :quantity # Quantity of the item in the line item
      t.decimal :price, precision: 10, scale: 2 # Total price for the line item
      t.decimal :price_per_unit, precision: 10, scale: 2 # Price per unit for the line item
      t.timestamps
    end
  end
end
