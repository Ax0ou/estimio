class AddAdministrativeFieldsToQuotes < ActiveRecord::Migration[7.1]
  def change
    add_column :quotes, :validity_duration, :string
    add_column :quotes, :execution_delay, :string
    add_column :quotes, :payment_terms, :string
  end
end
