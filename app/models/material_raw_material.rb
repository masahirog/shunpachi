class MaterialRawMaterial < ApplicationRecord
  belongs_to :material
  belongs_to :raw_material
  acts_as_list scope: :material

end
