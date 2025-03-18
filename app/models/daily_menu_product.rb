class DailyMenuProduct < ApplicationRecord
  belongs_to :daily_menu, counter_cache: true
  belongs_to :product, counter_cache: true
  has_many :store_daily_menu_products, dependent: :destroy
  accepts_nested_attributes_for :store_daily_menu_products, allow_destroy: true
  validates :product_id, uniqueness: { scope: :daily_menu_id, message: "はすでに献立に追加されています" }
end