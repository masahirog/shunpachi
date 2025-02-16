class MaterialFoodAdditive < ApplicationRecord
  belongs_to :material
  belongs_to :food_additive
end
