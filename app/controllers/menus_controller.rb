class MenusController < ApplicationController
  before_action :set_menu, only: %i[edit update destroy]


  def details
    @menu = Menu.includes(menu_materials: :material).find(params[:id])
    
    # 材料情報を取得
    menu_materials_data = @menu.menu_materials.map do |mm|
      {
        id: mm.id,
        name: mm.material.name,
        amount_used: mm.amount_used,
        unit: mm.material.recipe_unit_i18n, # enumの国際化された名前
        preparation: mm.preparation,
        cost_price: mm.cost_price
      }
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
          menu_materials: menu_materials_data
        }
      end
    end
  rescue => e
    Rails.logger.error "Error in details action: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    
    respond_to do |format|
      format.json { render json: { error: e.message }, status: :internal_server_error }
    end
  end

  def index
    @menus = Menu.includes(:menu_materials).all
  end

  def new
    @materials = Material.first(10)
    @menu = Menu.new
  end

  def create
    @menu = Menu.new(menu_params)
    if @menu.save
      redirect_to menus_path, notice: 'メニューを作成しました。'
    else
      render :new
    end
  end

  def edit
    material_ids = @menu.menu_materials.map(&:material_id)
    @materials = Material.includes(:food_ingredient).where(id: material_ids)
  end

  def update
    if @menu.update(menu_params)
      redirect_to menus_path, notice: 'メニューを更新しました。'
    else
      render :edit
    end
  end

  def destroy
    @menu.destroy
    redirect_to menus_path, notice: 'メニューを削除しました。'
  end

  private

  def set_menu
    @menu = Menu.includes(menu_materials: :material).find(params[:id])
  end

  def menu_params
    params.require(:menu).permit(:name, :category, :cook_before, :cook_on_the_day, :cost_price,
      :calorie,:protein,:lipid,:carbohydrate,:salt,
    menu_materials_attributes: [:id,:menu_id,:material_id,:amount_used,:preparation,:row_order,
      :gram_quantity,:calorie,:protein,:lipid,:carbohydrate,:salt,:source_group,:cost_price,:_destroy])

  end
end
