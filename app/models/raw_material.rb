class RawMaterial < ApplicationRecord
  has_many :material_raw_materials
  has_many :materials, through: :material_raw_materials
end
