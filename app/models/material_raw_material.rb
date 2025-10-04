class MaterialRawMaterial < ApplicationRecord
  belongs_to :material
  belongs_to :raw_material
  acts_as_list scope: :material

  validates :percentage, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
end
