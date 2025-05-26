class Quote < ApplicationRecord
  belongs_to :user
  belongs_to :client

  has_many :ai_messages, dependent: :destroy
end
