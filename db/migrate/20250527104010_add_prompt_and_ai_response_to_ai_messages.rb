class AddPromptAndAiResponseToAiMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :ai_messages, :prompt, :text
    add_column :ai_messages, :ai_response, :text
  end
end
