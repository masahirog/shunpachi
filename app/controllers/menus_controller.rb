class MenusController < ApplicationController
  before_action :set_menu, only: %i[edit update destroy calculate]

  def export_to_sheets
    # パラメータのバリデーション
    spreadsheet_id = params[:spreadsheet_id]&.strip
    sheet_name = params[:sheet_name]&.strip
    url_column = params[:url_column]&.strip&.upcase

    if spreadsheet_id.blank? || sheet_name.blank? || url_column.blank?
      redirect_to menus_path, alert: 'スプレッドシートID、シート名、URL列をすべて入力してください'
      return
    end

    service = GoogleSheetsService.new
    result = service.export_menu_costs(
      spreadsheet_id: spreadsheet_id,
      sheet_name: sheet_name,
      url_column: url_column
    )

    if result[:success]
      redirect_to menus_path, notice: result[:message]
    else
      redirect_to menus_path, alert: result[:error]
    end
  end

  def calculate
    # 現在のメニューの原価と栄養成分を再計算して返す（DBには保存しない）
    total_cost = 0.0
    total_calorie = 0.0
    total_protein = 0.0
    total_lipid = 0.0
    total_carbohydrate = 0.0
    total_salt = 0.0

    # 各menu_materialの原価と栄養成分を計算
    menu_materials_data = []

    @menu.menu_materials.includes(material: :food_ingredient).each do |mm|
      next unless mm.material

      mm_cost = 0.0
      mm_calorie = 0.0
      mm_protein = 0.0
      mm_lipid = 0.0
      mm_carbohydrate = 0.0
      mm_salt = 0.0
      mm_gram_quantity = 0.0

      # 原価計算: amount_used × material.recipe_unit_price
      if mm.material.recipe_unit_price.present? && mm.amount_used.present?
        mm_cost = (mm.amount_used.to_f * mm.material.recipe_unit_price.to_f).round(2)
        total_cost += mm_cost
      end

      # gram_quantity計算
      if mm.amount_used.present?
        if mm.material.recipe_unit_gram_quantity.present?
          # recipe_unit_gram_quantityが存在する場合: amount_used × recipe_unit_gram_quantity
          mm_gram_quantity = (mm.amount_used.to_f * mm.material.recipe_unit_gram_quantity.to_f).round(2)
        else
          # recipe_unit_gram_quantityが存在しない、またはfood_ingredientがない場合: amount_usedをそのまま使用
          mm_gram_quantity = mm.amount_used.to_f.round(2)
        end
      else
        mm_gram_quantity = 0.0
      end

      # 栄養成分計算: gram_quantity基準（food_ingredientが存在する場合のみ）
      if mm.material.food_ingredient.present? && mm_gram_quantity > 0
        food = mm.material.food_ingredient
        # 1gあたりの栄養成分をgram_quantityに応じて計算
        mm_calorie = (food.calorie.to_f * mm_gram_quantity).round(2)
        mm_protein = (food.protein.to_f * mm_gram_quantity).round(2)
        mm_lipid = (food.lipid.to_f * mm_gram_quantity).round(2)
        mm_carbohydrate = (food.carbohydrate.to_f * mm_gram_quantity).round(2)
        mm_salt = (food.salt.to_f * mm_gram_quantity).round(2)

        total_calorie += mm_calorie
        total_protein += mm_protein
        total_lipid += mm_lipid
        total_carbohydrate += mm_carbohydrate
        total_salt += mm_salt
      end

      # 各menu_materialのデータを配列に追加
      menu_materials_data << {
        id: mm.id,
        cost_price: mm_cost,
        gram_quantity: mm_gram_quantity,
        calorie: mm_calorie,
        protein: mm_protein,
        lipid: mm_lipid,
        carbohydrate: mm_carbohydrate,
        salt: mm_salt
      }
    end

    respond_to do |format|
      format.json do
        render json: {
          cost_price: total_cost.round(2),
          calorie: total_calorie.round(2),
          protein: total_protein.round(2),
          lipid: total_lipid.round(2),
          carbohydrate: total_carbohydrate.round(2),
          salt: total_salt.round(2),
          menu_materials: menu_materials_data
        }
      end
    end
  end

  def details
    @menu = Menu.includes(menu_materials: { material: :material_allergies }).for_company(current_company).find(params[:id])
    
    # 材料情報を取得
    menu_materials_data = @menu.menu_materials.map do |mm|
      {
        id: mm.id,
        material_id: mm.material_id,
        name: mm.material.name,
        amount_used: mm.amount_used,
        unit: mm.material.recipe_unit_i18n, # enumの国際化された名前
        preparation: mm.preparation,
        cost_price: mm.cost_price
      }
    end
    
    # アレルギー情報を取得
    allergens = []
    @menu.menu_materials.each do |mm|
      next unless mm.material
      mm.material.material_allergies.each do |ma|
        allergens << [ma.allergen, MaterialAllergy.allergens_i18n[ma.allergen]] if ma.allergen.present?
      end
    end
    
    respond_to do |format|
      format.json do
        render json: {
          id: @menu.id,
          name: @menu.name,
          category_name: @menu.category_i18n,
          cost_price: @menu.cost_price,
          calorie: @menu.calorie,
          protein: @menu.protein,
          lipid: @menu.lipid,
          carbohydrate: @menu.carbohydrate,
          salt: @menu.salt,
          menu_materials: menu_materials_data,
          allergens: allergens.uniq
        }
      end
    end
  end



  def index
    @menus = Menu.with_attached_image.for_company(current_company)

    # 検索機能
    if params[:query].present?
      @menus = @menus.where("name LIKE ?", "%#{params[:query]}%")
    end

    # カテゴリフィルター
    if params[:category].present?
      @menus = @menus.where(category: params[:category])
    end

    # 新しいものを上に表示
    @menus = @menus.order(id: :desc).paginate(page: params[:page], per_page: 30)
  end
  def new
    @materials = Material.joins(:vendor).where(vendors: { company: current_company }).limit(10)
    @menu = Menu.new
  end

  def create
    @menu = Menu.new(menu_params)
    @menu.company = current_company
    if @menu.save
      redirect_to menu_path(@menu), notice: 'メニューを作成しました。'
    else
      @materials = Material.joins(:vendor).where(vendors: { company: current_company }).limit(10)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    material_ids = @menu.menu_materials.map(&:material_id)
    @materials = Material.includes(:food_ingredient).joins(:vendor).where(id: material_ids, vendors: { company: current_company })
  end

  def copy
    original_menu = Menu.includes(menu_materials: :material).for_company(current_company).find(params[:id])
    
    @menu = original_menu.dup
    @menu.name = "#{original_menu.name}のコピー"
    
    # 関連するmenu_materialsも複製
    original_menu.menu_materials.each do |mm|
      @menu.menu_materials.build(
        material_id: mm.material_id,
        amount_used: mm.amount_used,
        preparation: mm.preparation,
        row_order: mm.row_order,
        gram_quantity: mm.gram_quantity,
        calorie: mm.calorie,
        protein: mm.protein,
        lipid: mm.lipid,
        carbohydrate: mm.carbohydrate,
        salt: mm.salt,
        source_group: mm.source_group,
        cost_price: mm.cost_price
      )
    end
    
    # コピー時は複製された材料を含めて表示
    material_ids = @menu.menu_materials.map(&:material_id).compact
    @materials = Material.includes(:food_ingredient).joins(:vendor).where(vendors: { company: current_company })
    @materials = @materials.where(id: material_ids) if material_ids.any?
    
    render :new
  end

  def show
    @menu = Menu.includes(menu_materials: { material: [:material_allergies, :vendor, :food_ingredient] }).for_company(current_company).find(params[:id])
  end

  def update
    if @menu.update(menu_params)
      redirect_to menu_path(@menu), notice: 'メニューを更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @menu.destroy
      redirect_to menus_path, notice: 'メニューを削除しました。', status: :see_other
    else
      redirect_to menu_path(@menu), alert: @menu.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  private

  def set_menu
    @menu = Menu.includes(menu_materials: { material: :food_ingredient }).for_company(current_company).find(params[:id])
  end

  def menu_params
    params.require(:menu).permit(:name, :category, :cook_before, :cook_on_the_day, :cost_price,
      :calorie,:protein,:lipid,:carbohydrate,:salt, :image,
    menu_materials_attributes: [:id,:menu_id,:material_id,:amount_used,:preparation,:row_order,
      :gram_quantity,:calorie,:protein,:lipid,:carbohydrate,:salt,:source_group,:cost_price,:_destroy])

  end
end
