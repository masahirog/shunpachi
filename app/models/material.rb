class Material < ApplicationRecord
  belongs_to :vendor
  belongs_to :food_ingredient
  has_many :menu_materials, dependent: :destroy
  has_many :material_allergies, dependent: :destroy
  has_many :material_food_additives, dependent: :destroy

  accepts_nested_attributes_for :material_allergies, allow_destroy: true
  accepts_nested_attributes_for :material_food_additives, allow_destroy: true

  validates :name, presence: true, uniqueness: true
end
