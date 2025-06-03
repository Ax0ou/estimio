class Section < ApplicationRecord
  belongs_to :quote
  has_many :line_items, dependent: :destroy
end
