class Product < ApplicationRecord
  UNITS = ["u", "m²", "h", "kg", "m³", "j", "g", "t", "l", "m"]

  UNIT_LABELS = {
    "u"     => "unité",
    "m²"    => "mètre carré",
    "h"     => "heure",
    "kg"    => "kilogramme",
    "m³"    => "mètre cube",
    "j"     => "jour",
    "g"     => "gramme",
    "t"     => "tonne",
    "l"     => "litre",
    "m"     => "mètre"
  }

  belongs_to :company
  validates :unit, inclusion: { in: UNITS }
end
