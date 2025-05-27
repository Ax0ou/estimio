class AiMessage < ApplicationRecord
  belongs_to :quote

  validates :content, presence: true
end
