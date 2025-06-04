class Quote < ApplicationRecord
  has_many :sections, dependent: :destroy
  has_many :ai_messages, through: :sections
  belongs_to :company
  belongs_to :client
end
