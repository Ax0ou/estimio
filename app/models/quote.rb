class Quote < ApplicationRecord
  has_many :sections, dependent: :destroy
  has_many :ai_messages, through: :sections
  belongs_to :company
  belongs_to :client

  enum status: { a_traiter: 0, envoye: 1 }

  def total_ht
    total = 0
    sections.each do |section|
      section.line_items.each do |line_item|
        total += line_item.price.to_f 
      end
    end
    total
  end

  def total_ttc
    total_ht * 1.1
  end

end
