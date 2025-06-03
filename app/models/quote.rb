class Quote < ApplicationRecord
  has_many :sections, dependent: :destroy
  belongs_to :company
end
