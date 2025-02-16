class Store < ApplicationRecord
  has_many :store_daily_menu_products, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
