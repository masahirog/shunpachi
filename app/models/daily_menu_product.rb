class DailyMenuProduct < ApplicationRecord
  belongs_to :daily_menu, optional: true
  belongs_to :product, optional: true
  has_many :store_daily_menu_products
end
