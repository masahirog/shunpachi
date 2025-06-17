class MaterialsController < ApplicationController
  before_action :set_material, only: %i[edit update destroy]
  def get_details
    material = Material.find(params[:id])
    food_ingredient = material.food_ingredient
    response_data = { 
      unit: material.recipe_unit_i18n,
      recipe_unit_gram_quantity: material.recipe_unit_gram_quantity,
      recipe_unit_price: material.recipe_unit_price
    }
    
    if food_ingredient.present?
      response_data[:food_ingredient] = {
        id: food_ingredient.id,
        name: food_ingredient.name,
        calorie: food_ingredient.calorie,
        protein: food_ingredient.protein,
        lipid: food_ingredient.lipid,
        carbohydrate: food_ingredient.carbohydrate,
        salt: food_ingredient.salt
      }
    end
    render json: response_data
  end
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
    @materials = @materials.order(id: :desc).paginate(page: params[:page], per_page: 30)

    # 検索機能
    if params[:query].present?
      @materials = @materials.where("name LIKE ?", "%#{params[:query]}%")
    end
    
    # カテゴリフィルター
    if params[:category].present?
      @materials = @materials.where(category: params[:category])
    end
    
    @materials = @materials.paginate(page: params[:page], per_page: 30)
  end

  def new
    @material = Material.new
  end


  def edit; end


  def create
    @material = Material.new(material_params)
    if @material.save
      save_allergens(@material)
      redirect_to materials_path, notice: '材料を作成しました。'
    else
      render :new
    end
  end

  def update
    # デバッグ用：パラメータを確認
    Rails.logger.debug "Params: #{params.inspect}"
    
    if @material.update(material_params)
      # デバッグ用：更新成功を確認
      Rails.logger.debug "Material updated successfully"
      
      save_allergens(@material)
      redirect_to materials_path, notice: '材料を更新しました。'
    else
      # デバッグ用：エラーを確認
      Rails.logger.debug "Update failed: #{@material.errors.full_messages}"
      
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
    params.require(:material).permit(:vendor_id, :food_ingredient_id, :name, :category, :recipe_unit,
     :recipe_unit_price, :memo, :unused_flag, :recipe_unit_gram_quantity,
    material_raw_materials_attributes: [:id, :raw_material_id, :quantity_ratio, :position, :_destroy])
  end

  def save_allergens(material)
    # 既存のアレルゲン情報を削除
    material.material_allergies.destroy_all
    
    # 選択されたアレルゲンを保存
    if params[:material][:allergens].present?
      params[:material][:allergens].each do |allergen|
        next if allergen.blank?
        material.material_allergies.create!(allergen: allergen)
      end
    end
  rescue => e
    Rails.logger.error "Failed to save allergens: #{e.message}"
  end

end
