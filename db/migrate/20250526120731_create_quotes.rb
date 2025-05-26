class CreateQuotes < ActiveRecord::Migration[7.1]
  def change
    create_table :quotes do |t|
      t.references :craftman, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
      t.string :title
      t.string :project_type
      t.references :ai_message, null: false, foreign_key: true

      t.timestamps
    end
  end
end
