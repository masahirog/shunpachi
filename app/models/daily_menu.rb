class DailyMenu < ApplicationRecord
  has_many :daily_menu_products, dependent: :destroy
  accepts_nested_attributes_for :daily_menu_products, allow_destroy: true

  validates :date, presence: true, uniqueness: true
end
