class CreateClients < ActiveRecord::Migration[7.1]
  def change
    create_table :clients do |t|
      t.string :first_name
      t.string :last_name
      t.string :address
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
