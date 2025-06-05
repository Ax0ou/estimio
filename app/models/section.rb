class Section < ApplicationRecord
  has_many :ai_messages, dependent: :destroy
  belongs_to :quote
  has_many :line_items, dependent: :destroy

  def total_ht
    line_items.sum do |line_item|
      line_item.price * line_item.quantity

    end.to_f
  end
  def total_ttc
    total_ht * 1.1
  end
end
