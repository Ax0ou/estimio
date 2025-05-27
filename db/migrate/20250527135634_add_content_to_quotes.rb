class AddContentToQuotes < ActiveRecord::Migration[7.1]
  def change
    add_column :quotes, :content, :text
  end
end
