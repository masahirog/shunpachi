class Material < ApplicationRecord
  belongs_to :vendor
  belongs_to :food_ingredient, optional: true

  has_many :menu_materials, dependent: :destroy
  has_many :material_allergies, dependent: :destroy
  has_many :material_food_additives, dependent: :destroy
  accepts_nested_attributes_for :material_food_additives, allow_destroy: true

  validates :name, presence: true, uniqueness: true

  enum recipe_unit: {gram:1,ml:2,pack:3,hon:4,ko:5,mai:6}
  enum category: {food:1,packed:2,other:3}
end
