class UpdateTablesForNewAssociations < ActiveRecord::Migration[7.1]
  def change
    # Ajouter company_id aux users
    add_reference :users, :company, foreign_key: true
    add_column :users, :company_position, :string
    remove_column :users, :address, :string
    remove_column :users, :siret, :string
    remove_column :users, :company_name, :string

    # Ajouter company_id aux clients
    add_reference :clients, :company, foreign_key: true
    remove_reference :clients, :user, foreign_key: true
    add_column :clients, :city, :string
    add_column :clients, :postal_code, :string
    add_column :clients, :phone_number, :string
    add_column :clients, :email, :string

    # Ajouter company_id aux quotes
    add_reference :quotes, :company, foreign_key: true
    remove_reference :quotes, :user, foreign_key: true
    remove_column :quotes, :project_type, :string

    # Changer quote_id -> section_id dans ai_messages
    remove_reference :ai_messages, :quote, foreign_key: true
    add_reference :ai_messages, :section, foreign_key: true
  end
end
