class Vendor < ApplicationRecord
  include TenantScoped
  
  has_many :materials, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :company_id }
end
