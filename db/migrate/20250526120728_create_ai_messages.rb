class CreateAiMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :ai_messages do |t|
      t.string :description
      t.text :content
      t.references :quote, null: false, foreign_key: true

      t.timestamps
    end
  end
end
