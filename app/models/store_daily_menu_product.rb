class StoreDailyMenuProduct < ApplicationRecord
  belongs_to :store, counter_cache: true
  belongs_to :daily_menu_product, counter_cache: true
end
