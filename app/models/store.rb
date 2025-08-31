class Store < ApplicationRecord
  include TenantScoped
  
  has_many :store_daily_menu_products, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :company_id }
end
