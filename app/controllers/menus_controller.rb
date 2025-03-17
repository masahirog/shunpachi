class MenusController < ApplicationController
  before_action :set_menu, only: %i[edit update destroy]

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
