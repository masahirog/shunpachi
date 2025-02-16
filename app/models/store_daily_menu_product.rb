class StoreDailyMenuProduct < ApplicationRecord
  belongs_to :daily_menu_product, optional: true
  belongs_to :store, optional: true
end
