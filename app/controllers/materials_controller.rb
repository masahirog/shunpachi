class MaterialsController < ApplicationController
  before_action :set_material, only: %i[edit update destroy]

  def search
    query = params[:q]
    materials = if query.present?
                         Material.where("name LIKE ?", "%#{query}%")
                       else
                         Material.none
                       end

    render json: materials.select(:id, :name) # 必要なデータのみ返す
  end

  def index
    @materials = Material.order(id: :desc).paginate(page: params[:page], per_page: 30)
  end

  def new
    @material = Material.new
  end

  def create
    @material = Material.new(material_params)
    if @material.save
      redirect_to materials_path, notice: '材料を作成しました。'
    else
      render :new
    end
  end

  def edit; end

  def update
    binding.pry
    if @material.update(material_params)
      redirect_to materials_path, notice: '材料を更新しました。'
    else
      render :edit
    end
  end

  def destroy
    @material.destroy
    redirect_to materials_path, notice: '材料を削除しました。'
  end

  private

  def set_material
    @material = Material.find(params[:id])
  end

  def material_params
    params.require(:material).permit(:vendor_id, :food_ingredient_id, :name, :food_label_name, :category, :recipe_unit, :recipe_unit_price, :memo, :unused_flag)
  end
end
