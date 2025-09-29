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

  # 価格変更時の連動更新
  after_update :update_product_costs, if: :saved_change_to_cost_price?

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

  def update_product_costs
    return unless saved_change_to_cost_price?

    Rails.logger.info "Menu##{id}: 価格更新処理開始 (#{saved_change_to_cost_price[0]} → #{cost_price})"

    # 関連するproductのcost_price更新
    affected_products = product_menus.includes(:product).map(&:product).uniq.compact
    updated_products = []

    affected_products.each do |product|
      total_cost = product.product_menus.includes(:menu).sum { |pm| pm.menu&.cost_price.to_f }
      product.cost_price = total_cost
      updated_products << product
    end

    if updated_products.any?
      Product.import updated_products,
                    on_duplicate_key_update: [:cost_price],
                    validate: false
      Rails.logger.info "  - #{updated_products.size}件のproduct更新完了"
    end
  end
end
