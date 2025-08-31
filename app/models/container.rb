class Container < ApplicationRecord
  include TenantScoped
  
  has_many :products, counter_cache: true
  validates :name, presence: true, uniqueness: { scope: :company_id }
end
