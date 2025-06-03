class Section < ApplicationRecord
  has_many :ai_messages, dependent: :destroy
  belongs_to :quote
  has_many :line_items, dependent: :destroy
end
