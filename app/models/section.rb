class Section < ApplicationRecord
  has_many :ai_messages, dependent: :destroy
  belongs_to :quote
  has_many :line_items, -> { order(:position) }, dependent: :destroy

  def total_ht
    total = 0
    line_items.each do |line_item|
      total += line_item.price.to_f
    end
    total
  end


  def total_ttc
    total_ht * 1.1
  end
end
