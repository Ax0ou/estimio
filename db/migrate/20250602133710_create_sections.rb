class CreateSections < ActiveRecord::Migration[7.1]
  def change
    create_table :sections do |t|
      t.references :quote, null: false, foreign_key: true # Reference to the quote this section belongs to
      t.string :description # Description of the section
      t.timestamps
    end
  end
end
