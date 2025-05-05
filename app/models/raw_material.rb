class RawMaterial < ApplicationRecord
  has_many :material_raw_materials
  has_many :materials, through: :material_raw_materials

  validates :name, presence: true, uniqueness: true
  
  enum category: { food: 1, additive: 2, other: 3 }
  
  def display_name
    name
  end
end
