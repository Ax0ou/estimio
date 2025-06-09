class LineItem < ApplicationRecord
  UNITS = ['u', 'm²', 'ml', 'h', 'm³', 'kg'].freeze
  belongs_to :section
  before_save :set_price

  private

  def set_price
    if price_per_unit.present? && quantity.present?
      self.price = price_per_unit * quantity
    end
  end
end
