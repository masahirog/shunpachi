class ProductMenu < ApplicationRecord
  belongs_to :product, optional: true
  belongs_to :menu, optional: true
end
