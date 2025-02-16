class DailyMenu < ApplicationRecord
  has_many :daily_menu_details, dependent: :destroy
  accepts_nested_attributes_for :daily_menu_details, allow_destroy: true

  validates :date, presence: true, uniqueness: true
end
