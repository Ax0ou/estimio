class CreateCraftmen < ActiveRecord::Migration[7.1]
  def change
    create_table :craftmen do |t|
      t.string :first_name
      t.string :last_name
      t.string :siret
      t.string :company_name
      t.string :address
      t.string :phone_number

      t.timestamps
    end
  end
end
