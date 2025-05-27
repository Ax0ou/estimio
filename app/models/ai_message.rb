class AiMessage < ApplicationRecord
  belongs_to :quote

  validates :prompt, presence: true
end
