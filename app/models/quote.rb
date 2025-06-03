class Quote < ApplicationRecord
  has_many :ai_messages, through: :sections
  has_many :sections, dependent: :destroy
  belongs_to :company
  belongs_to :client
end
