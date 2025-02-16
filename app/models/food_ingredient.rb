class FoodIngredient < ApplicationRecord
  has_many :materials

  validates :name, presence: true, uniqueness: true
end
