class Company < ApplicationRecord
  has_many :clients, dependent: :destroy
  has_many :quotes, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :products, dependent: :destroy
end
