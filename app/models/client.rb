# app/models/client.rb

class Client < ApplicationRecord
  belongs_to :user
  has_many   :quotes, dependent: :destroy

  # validations
  validates :first_name, :last_name, :address, presence: true
  # phone_number est facultatif
end
