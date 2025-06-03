class CreateCompanies < ActiveRecord::Migration[7.1]
  def change
    create_table :companies do |t|
      t.string :name # Name of the company
      t.string :siret # SIRET number for the company
      t.string :tva_number # TVA number for the company
      t.integer :number_of_employees # Number of employees in the company
      t.string :address # Address of the company
      t.string :city  # City where the company is located
      t.string :postal_code # Postal code of the company
      t.timestamps
    end
  end
end
