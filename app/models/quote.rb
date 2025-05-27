# app/models/quote.rb

class Quote < ApplicationRecord
  belongs_to :user
  belongs_to :client

  has_many :quote_items, dependent: :destroy
  has_many :ai_messages, dependent: :destroy

  accepts_nested_attributes_for :client

  validates :content, presence: true
end

