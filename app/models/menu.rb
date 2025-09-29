class Menu < ApplicationRecord
  include TenantScoped

  has_many :menu_materials, -> { order(:row_order) }, dependent: :destroy
  accepts_nested_attributes_for :menu_materials, allow_destroy: true

  has_many :product_menus, dependent: :destroy
  has_many :food_ingredients, through: :menu_materials

  has_one_attached :image

  enum category: { 容器: 0, 温菜: 1, 冷菜: 2, スイーツ: 3 }
  validates :name, presence: true, uniqueness: { scope: :company_id }
  validates :category, presence: true

  # 削除制限
  before_destroy :check_usage

  def in_use?
    product_menus.exists?
  end

  def usage_count
    product_menus.count
  end

  private

  def check_usage
    if in_use?
      errors.add(:base, "このメニューは#{usage_count}件の商品で使用されているため削除できません")
      throw(:abort)
    end
  end
end
