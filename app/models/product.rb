class Product < ApplicationRecord
  has_many :product_menus, -> { order(:row_order) }, dependent: :destroy
  accepts_nested_attributes_for :product_menus, allow_destroy: true
  has_many :daily_menu_products

  enum category: { souzai: 0, bento: 1, hankanhin: 2 }
  
  validates :name, presence: true, uniqueness: true
  validates :food_label_name, presence: true
  validates :sell_price, :cost_price, numericality: { greater_than_or_equal_to: 0 }
end
