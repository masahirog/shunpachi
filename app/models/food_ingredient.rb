class FoodIngredient < ApplicationRecord
  belongs_to :company, optional: true  # NULLの場合は共通データ
  
  has_many :materials

  validates :name, presence: true, uniqueness: { scope: :company_id }
  
  # ハイブリッドスコープ: 共通データ + 自社データ
  scope :for_company, ->(company) { 
    where("company_id IS NULL OR company_id = ?", company&.id)
  }
  
  # 共通データのみ
  scope :common, -> { where(company_id: nil) }
  
  # 特定企業専用データのみ
  scope :company_only, ->(company) { where(company: company) }
  
  def display_name
    suffix = company_id.present? ? " (自社専用)" : ""
    "#{name}#{suffix}"
  end
  
  def shared?
    company_id.nil?
  end
end
