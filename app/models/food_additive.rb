class FoodAdditive < ApplicationRecord
  has_many :material_food_additives
  validates :name, presence: true, uniqueness: true
end
