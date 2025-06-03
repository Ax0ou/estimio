class Quote < ApplicationRecord
  has_many :sections, dependent: :destroy
  belongs_to :company
  has_many :ai_messages, through: :sections
end
