class AiMessage < ApplicationRecord
  belongs_to :section

  # validates :prompt, presence: true
end
