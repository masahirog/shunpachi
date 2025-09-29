class FoodIngredient < ApplicationRecord
  belongs_to :company, optional: true  # NULLの場合は共通データ

  has_many :materials

  validates :name, presence: true, uniqueness: { scope: :company_id }

  # 栄養成分変更時の連動更新
  after_update :update_related_nutrition, if: :nutrition_changed?
  
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

  def nutrition_changed?
    saved_change_to_calorie? || saved_change_to_protein? ||
    saved_change_to_lipid? || saved_change_to_carbohydrate? ||
    saved_change_to_salt?
  end

  def update_related_nutrition
    Rails.logger.info "FoodIngredient##{id}: 栄養成分更新処理開始"

    # 1. 関連する全MenuMaterialを取得
    menu_materials = MenuMaterial.joins(:material).where(materials: { food_ingredient_id: id })

    if menu_materials.empty?
      Rails.logger.info "  - 関連するmenu_materialsがありません"
      return
    end

    # 2. MenuMaterialの栄養成分をバルク更新
    updated_menu_materials = []
    menu_materials.includes(:material).find_each do |mm|
      next unless mm.gram_quantity.present?

      # 1gあたりの栄養成分をgram_quantityに応じて計算
      mm.calorie = (calorie.to_f * mm.gram_quantity.to_f).round(2)
      mm.protein = (protein.to_f * mm.gram_quantity.to_f).round(2)
      mm.lipid = (lipid.to_f * mm.gram_quantity.to_f).round(2)
      mm.carbohydrate = (carbohydrate.to_f * mm.gram_quantity.to_f).round(2)
      mm.salt = (salt.to_f * mm.gram_quantity.to_f).round(2)

      updated_menu_materials << mm
    end

    if updated_menu_materials.any?
      MenuMaterial.import updated_menu_materials,
                         on_duplicate_key_update: [:calorie, :protein, :lipid, :carbohydrate, :salt],
                         validate: false
      Rails.logger.info "  - #{updated_menu_materials.size}件のmenu_materials更新完了"
    end

    # 3. 関連するMenuの栄養成分をバルク更新
    affected_menus = menu_materials.map(&:menu).uniq.compact
    updated_menus = []

    affected_menus.each do |menu|
      menu.calorie = menu.menu_materials.sum(:calorie)
      menu.protein = menu.menu_materials.sum(:protein)
      menu.lipid = menu.menu_materials.sum(:lipid)
      menu.carbohydrate = menu.menu_materials.sum(:carbohydrate)
      menu.salt = menu.menu_materials.sum(:salt)

      updated_menus << menu
    end

    if updated_menus.any?
      Menu.import updated_menus,
                  on_duplicate_key_update: [:calorie, :protein, :lipid, :carbohydrate, :salt],
                  validate: false
      Rails.logger.info "  - #{updated_menus.size}件のmenu更新完了"

      # 4. Menuに紐づくProductの栄養成分をバルク更新
      update_products_nutrition(updated_menus)
    end
  end

  def update_products_nutrition(menus)
    affected_products = ProductMenu.where(menu_id: menus.map(&:id))
                                  .includes(:product)
                                  .map(&:product)
                                  .uniq
                                  .compact

    updated_products = []
    affected_products.each do |product|
      product.calorie = product.product_menus.includes(:menu).sum { |pm| pm.menu&.calorie.to_f }
      product.protein = product.product_menus.includes(:menu).sum { |pm| pm.menu&.protein.to_f }
      product.lipid = product.product_menus.includes(:menu).sum { |pm| pm.menu&.lipid.to_f }
      product.carbohydrate = product.product_menus.includes(:menu).sum { |pm| pm.menu&.carbohydrate.to_f }
      product.salt = product.product_menus.includes(:menu).sum { |pm| pm.menu&.salt.to_f }

      updated_products << product
    end

    if updated_products.any?
      Product.import updated_products,
                    on_duplicate_key_update: [:calorie, :protein, :lipid, :carbohydrate, :salt],
                    validate: false
      Rails.logger.info "  - #{updated_products.size}件のproduct更新完了"
    end
  end
end
