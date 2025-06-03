class Quote < ApplicationRecord
  has_many :ai_messages, dependent: :destroy
  has_many :sections, dependent: :destroy
  belongs_to :user
  belongs_to :client
end
