class AddPhoneNumberToClients < ActiveRecord::Migration[7.1]
  def change
    add_column :clients, :phone_number, :string
  end
end
