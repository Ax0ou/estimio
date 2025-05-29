class AddRoleToAiMessage < ActiveRecord::Migration[7.1]
  def change
    add_column :ai_messages, :role, :string
  end
end
