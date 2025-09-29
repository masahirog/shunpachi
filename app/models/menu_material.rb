class MenuMaterial < ApplicationRecord
  belongs_to :menu, counter_cache: true
  belongs_to :material, optional: true
  enum source_group: { A: 1, B: 2, C: 3, D: 4, E: 5, F: 6, G: 7, H: 8 }

  acts_as_list scope: :menu, column: :row_order

  # 使用量変更時の連動更新
  after_update :update_costs_and_nutrition, if: :amount_used_changed?

  private

  def amount_used_changed?
    saved_change_to_amount_used?
  end

  def update_costs_and_nutrition
    Rails.logger.info "MenuMaterial##{id}: 使用量更新処理開始 (#{saved_change_to_amount_used[0]} → #{amount_used})"

    # 1. 自身のcost_priceを更新
    if material&.recipe_unit_price.present?
      new_cost = (amount_used.to_f * material.recipe_unit_price.to_f).round(2)
      update_column(:cost_price, new_cost)
    end

    # 2. 自身の栄養成分を更新（gram_quantityも材料の単位に応じて再計算）
    if material.present?
      # gram_quantityの再計算
      new_gram_quantity = amount_used.to_f * material.recipe_unit_gram_quantity.to_f
      update_column(:gram_quantity, new_gram_quantity)

      # 栄養成分の再計算
      if material.food_ingredient.present? && new_gram_quantity > 0
        food = material.food_ingredient
        # 1gあたりの栄養成分をgram_quantityに応じて計算
        update_columns(
          calorie: (food.calorie.to_f * new_gram_quantity).round(2),
          protein: (food.protein.to_f * new_gram_quantity).round(2),
          lipid: (food.lipid.to_f * new_gram_quantity).round(2),
          carbohydrate: (food.carbohydrate.to_f * new_gram_quantity).round(2),
          salt: (food.salt.to_f * new_gram_quantity).round(2)
        )
      end
    end

    # 3. 親のMenuを更新（コールバックをスキップ）
    update_parent_menu
  end

  def update_parent_menu
    return unless menu

    # Menuの合計を再計算
    total_cost = menu.menu_materials.sum(:cost_price)
    total_calorie = menu.menu_materials.sum(:calorie)
    total_protein = menu.menu_materials.sum(:protein)
    total_lipid = menu.menu_materials.sum(:lipid)
    total_carbohydrate = menu.menu_materials.sum(:carbohydrate)
    total_salt = menu.menu_materials.sum(:salt)

    # update_columnsでコールバックをスキップ
    menu.update_columns(
      cost_price: total_cost,
      calorie: total_calorie,
      protein: total_protein,
      lipid: total_lipid,
      carbohydrate: total_carbohydrate,
      salt: total_salt
    )

    # 4. Menuに紐づくProductを更新
    update_products_from_menu(menu)
  end

  def update_products_from_menu(menu)
    affected_products = menu.product_menus.includes(:product).map(&:product).uniq.compact

    affected_products.each do |product|
      # 全メニューの合計を再計算
      total_cost = product.product_menus.includes(:menu).sum { |pm| pm.menu&.cost_price.to_f }
      total_calorie = product.product_menus.includes(:menu).sum { |pm| pm.menu&.calorie.to_f }
      total_protein = product.product_menus.includes(:menu).sum { |pm| pm.menu&.protein.to_f }
      total_lipid = product.product_menus.includes(:menu).sum { |pm| pm.menu&.lipid.to_f }
      total_carbohydrate = product.product_menus.includes(:menu).sum { |pm| pm.menu&.carbohydrate.to_f }
      total_salt = product.product_menus.includes(:menu).sum { |pm| pm.menu&.salt.to_f }

      product.update_columns(
        cost_price: total_cost,
        calorie: total_calorie,
        protein: total_protein,
        lipid: total_lipid,
        carbohydrate: total_carbohydrate,
        salt: total_salt
      )
    end

    Rails.logger.info "  - #{affected_products.size}件のproduct更新完了"
  end
end
