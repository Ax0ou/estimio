class CreateAiMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :ai_messages do |t|
      t.string :description
      t.text :content

      t.timestamps
    end
  end
end
