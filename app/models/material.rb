class Material < ApplicationRecord
  belongs_to :vendor
  belongs_to :food_ingredient, optional: true

  has_many :menu_materials, dependent: :destroy
  has_many :material_allergies, dependent: :destroy

  has_many :material_raw_materials, -> { order(:position) }, dependent: :destroy
  has_many :raw_materials, through: :material_raw_materials
  
  accepts_nested_attributes_for :material_raw_materials, allow_destroy: true

  validates :name, presence: true, uniqueness: { scope: :vendor_id }
  validates :recipe_unit_gram_quantity, presence: true, numericality: { greater_than: 0 }

  # 削除制限
  before_destroy :check_usage

  # 価格変更時の連動更新
  after_update :update_related_costs, if: :saved_change_to_recipe_unit_price?

  def in_use?
    menu_materials.exists?
  end

  def usage_count
    menu_materials.count
  end

  private

  def check_usage
    if in_use?
      errors.add(:base, "この材料は#{usage_count}件のメニューで使用されているため削除できません")
      throw(:abort)
    end
  end

  def update_related_costs
    return unless saved_change_to_recipe_unit_price?

    Rails.logger.info "Material##{id}: 価格更新処理開始 (#{saved_change_to_recipe_unit_price[0]} → #{recipe_unit_price})"

    # 1. menu_materialsのcost_price更新
    updated_menu_materials = []
    menu_materials.includes(:menu).find_each do |mm|
      new_cost = (mm.amount_used.to_f * recipe_unit_price.to_f).round(2)
      mm.cost_price = new_cost
      updated_menu_materials << mm
    end

    if updated_menu_materials.any?
      MenuMaterial.import updated_menu_materials,
                          on_duplicate_key_update: [:cost_price],
                          validate: false
      Rails.logger.info "  - #{updated_menu_materials.size}件のmenu_materials更新完了"
    end

    # 2. 関連するmenuのcost_price更新
    affected_menus = menu_materials.map(&:menu).uniq.compact
    updated_menus = []

    affected_menus.each do |menu|
      total_cost = menu.menu_materials.sum(:cost_price)
      menu.cost_price = total_cost
      updated_menus << menu
    end

    if updated_menus.any?
      Menu.import updated_menus,
                  on_duplicate_key_update: [:cost_price],
                  validate: false
      Rails.logger.info "  - #{updated_menus.size}件のmenu更新完了"

      # 3. menuに紐づくproductのcost_price更新
      update_products_from_menus(updated_menus)
    end
  end

  def update_products_from_menus(menus)
    affected_products = ProductMenu.where(menu_id: menus.map(&:id))
                                  .includes(:product)
                                  .map(&:product)
                                  .uniq
                                  .compact

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

  enum recipe_unit: {gram:1,ml:2,pack:3,hon:4,ko:5,mai:6}
  enum category: {food:1,packed:2,other:3}


  def raw_materials_display
    material_raw_materials.includes(:raw_material).order(:position).map do |mrm|
      mrm.raw_material.display_name
    end.join('、')
  end
end
