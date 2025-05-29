class ToolCall < ApplicationRecord
  belongs_to :ai_message
  acts_as_tool_call
end
