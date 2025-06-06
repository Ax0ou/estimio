class Quote < ApplicationRecord
  has_many :sections, dependent: :destroy
  has_many :ai_messages, through: :sections
  belongs_to :company
  belongs_to :client

  enum status: { a_traiter: 0, envoye: 1 }

  def total_ht
    sections.sum do |section|
      section.total_ht

    end
  end

  def total_ttc
    total_ht * 1.1
  end

end
