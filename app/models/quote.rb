class Quote < ApplicationRecord
  has_many :sections, dependent: :destroy
  has_many :ai_messages, through: :sections
  belongs_to :company
  belongs_to :client

  enum status: { a_traiter: 0, envoye: 1, en_cours: 2, realise: 3 }

  def total_ht
    sections.includes(:line_items).sum(&:total_ht)
  end

  def total_ttc
    total_ht * 1.1
  end

end
