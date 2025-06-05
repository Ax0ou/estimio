class AddStatusToQuotes < ActiveRecord::Migration[7.1]
  def change
    add_column :quotes, :status, :integer, default: 0, null: false
  end
end
