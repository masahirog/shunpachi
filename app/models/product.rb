class Product < ApplicationRecord
  has_many :product_menus, -> { order(:row_order) }, dependent: :destroy
  accepts_nested_attributes_for :product_menus, allow_destroy: true
  has_many :daily_menu_details

  enum category: { A: 0, B: 1, C: 2, D: 3, E: 4, F: 5 }
  
  validates :name, presence: true, uniqueness: true
  validates :food_label_name, presence: true
  validates :sell_price, :cost_price, numericality: { greater_than_or_equal_to: 0 }
end
