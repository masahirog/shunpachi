class MenusController < ApplicationController
  before_action :set_menu, only: %i[edit update destroy]


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
      redirect_to menus_path, notice: 'メニューを作成しました。'
    else
      @materials = Material.joins(:vendor).where(vendors: { company: current_company }).limit(10)
      render :new
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
    @menu = Menu.includes(menu_materials: { material: :material_allergies }).for_company(current_company).find(params[:id])
  end

  def update
    if @menu.update(menu_params)
      redirect_to menus_path, notice: 'メニューを更新しました。'
    else
      render :edit
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
    @menu = Menu.includes(menu_materials: :material).for_company(current_company).find(params[:id])
  end

  def menu_params
    params.require(:menu).permit(:name, :category, :cook_before, :cook_on_the_day, :cost_price,
      :calorie,:protein,:lipid,:carbohydrate,:salt, :image,
    menu_materials_attributes: [:id,:menu_id,:material_id,:amount_used,:preparation,:row_order,
      :gram_quantity,:calorie,:protein,:lipid,:carbohydrate,:salt,:source_group,:cost_price,:_destroy])

  end
end
