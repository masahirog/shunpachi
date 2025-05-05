class RawMaterialsController < ApplicationController
  before_action :set_raw_material, only: %i[edit update destroy]

  def index
    @raw_materials = RawMaterial.all.paginate(page: params[:page], per_page: 30)
  end

  def new
    @raw_material = RawMaterial.new
  end

  def create
    @raw_material = RawMaterial.new(raw_material_params)
    if @raw_material.save
      redirect_to raw_materials_path, notice: '原材料を作成しました。'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @raw_material.update(raw_material_params)
      redirect_to raw_materials_path, notice: '原材料を更新しました。'
    else
      render :edit
    end
  end

  def destroy
    @raw_material.destroy
    redirect_to raw_materials_path, notice: '原材料を削除しました。'
  end

  private

  def set_raw_material
    @raw_material = RawMaterial.find(params[:id])
  end

  def raw_material_params
    params.require(:raw_material).permit(:name, :category, :description)
  end
end