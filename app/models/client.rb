class Client < ApplicationRecord
  belongs_to :company
  has_many :quotes, dependent: :destroy
end
