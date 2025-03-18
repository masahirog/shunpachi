class ProductMenu < ApplicationRecord
  belongs_to :product, counter_cache: true
  belongs_to :menu, counter_cache: true
end
