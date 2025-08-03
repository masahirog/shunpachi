class RawMaterialsController < ApplicationController
  before_action :set_raw_material, only: %i[edit update destroy show]

  def index
    @raw_materials = RawMaterial.includes(:materials).all
    
    # 検索機能
    if params[:query].present?
      @raw_materials = @raw_materials.where("name LIKE ?", "%#{params[:query]}%")
    end
    
    # カテゴリーフィルター
    if params[:category].present?
      @raw_materials = @raw_materials.where(category: params[:category])
    end
    
    # 新しいものを上に表示
    @raw_materials = @raw_materials.order(id: :desc).paginate(page: params[:page], per_page: 30)
  end

  def new
    @raw_material = RawMaterial.new
  end

  def show
    respond_to do |format|
      format.html { redirect_to edit_raw_material_path(@raw_material) }
      format.json {
        render json: {
          id: @raw_material.id,
          name: @raw_material.name,
          category: @raw_material.category,
          category_name: @raw_material.category ? t("enums.raw_material.category.#{@raw_material.category}") : nil,
          description: @raw_material.description,
          materials_count: @raw_material.materials.count,
          updated_at_formatted: @raw_material.updated_at.strftime("%Y年%m月%d日 %H:%M")
        }
      }
    end
  end
  
  def create
    @raw_material = RawMaterial.new(raw_material_params)
    
    respond_to do |format|
      if @raw_material.save
        format.html { redirect_to raw_materials_path, notice: '原材料を作成しました。' }
        format.json { render json: @raw_material, status: :created }
      else
        format.html { render :new }
        format.json { render json: { errors: @raw_material.errors.full_messages }, status: :unprocessable_entity }
      end
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