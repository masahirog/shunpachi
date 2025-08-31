module TenantScoped
  extend ActiveSupport::Concern
  
  included do
    belongs_to :company
    validates :company_id, presence: true
    
    scope :for_company, ->(company) { where(company: company) }
    
    # デフォルトスコープで現在の会社のレコードのみを取得
    # 注意：これを使用する場合は慎重に検討すること
    # scope :current_company, -> { where(company: Current.company) if Current.company.present? }
  end
  
  class_methods do
    # 現在の会社のスコープを適用するヘルパーメソッド
    def scoped_to_company(company)
      where(company: company)
    end
  end
end