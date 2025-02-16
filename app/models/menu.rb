class Menu < ApplicationRecord
  has_many :menu_materials, -> { order(:row_order) }, dependent: :destroy
  accepts_nested_attributes_for :menu_materials, allow_destroy: true

  has_many :product_menus, dependent: :destroy
  has_many :food_ingredients, through: :menu_materials

  enum category: { 容器: 0, 温菜: 1, 冷菜: 2, スイーツ: 3 }

  validates :name, presence: true
  validates :category, presence: true
end
