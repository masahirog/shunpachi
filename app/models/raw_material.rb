class RawMaterial < ApplicationRecord
  belongs_to :company, optional: true  # NULLの場合は共通データ
  
  has_many :material_raw_materials
  has_many :materials, through: :material_raw_materials

  validates :name, presence: true, uniqueness: { scope: :company_id }
  validates :category, presence: true

  # 共通データの編集を防ぐ
  before_update :prevent_shared_update
  before_destroy :prevent_shared_destroy

  enum category: { food: 1, additive: 2, other: 3 }
  
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

  private

  def prevent_shared_update
    if shared? && !company_id_changed?
      errors.add(:base, '共通データは編集できません')
      throw(:abort)
    end
  end

  def prevent_shared_destroy
    if shared?
      errors.add(:base, '共通データは削除できません')
      throw(:abort)
    end
  end
end
