class Client < ApplicationRecord
  belongs_to :company
  has_many :quotes, dependent: :destroy

  def full_name
    "#{first_name} #{last_name}".strip
  end
end
