class MaterialAllergy < ApplicationRecord
  belongs_to :material, optional: true
end
