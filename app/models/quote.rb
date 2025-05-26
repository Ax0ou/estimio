class Quote < ApplicationRecord
  belongs_to :craftman
  belongs_to :client
  belongs_to :ai_message
end
