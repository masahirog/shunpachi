class ProductsController < ApplicationController
  before_action :set_product, only: %i[edit update destroy]

  def index
    @products = Product.all.paginate(page: params[:page], per_page: 30)
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to products_path, notice: '商品を作成しました。'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @product.update(product_params)
      redirect_to products_path, notice: '商品を更新しました。'
    else
      render :edit
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: '商品を削除しました。'
  end

  # 原材料表示の自動生成アクション
  def generate_raw_materials_display
    if params[:id].present?
      # 既存の商品の場合（memberアクション）
      @product = Product.find(params[:id])
    elsif params['product-id'].present? && !params['product-id'].empty?
      # hidden_field_tagから送られてきた場合
      @product = Product.find(params['product-id'])
    else
      # 新規作成の場合（collectionアクション）
      begin
        if params[:product].present?
          @product = Product.new(product_params)
        else
          @product = Product.new
        end
      rescue ActionController::ParameterMissing => e
        # パラメータがない場合は空のオブジェクトを作成
        @product = Product.new
      end
    end
    
    # 食品原材料と添加物原材料を計算
    food_contents = calculate_raw_materials_display(@product, 'food')
    additive_contents = calculate_raw_materials_display(@product, 'additive')
    
    # アレルギー情報を計算
    allergens = calculate_allergens(@product)
    
    render json: {
      food_contents: food_contents,
      additive_contents: additive_contents,
      allergens: allergens
    }
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :food_label_name, :sell_price, :cost_price, :category, :introduction, :memo, :image,
     :serving_infomation, :raw_materials_food_contents, :raw_materials_additive_contents, :calorie, :protein, :lipid, :carbohydrate, :salt, :how_to_save, :sales_unit_amount, :unused_flag,
     product_menus_attributes: [:id, :menu_id, :product_id, :row_order, :_destroy])
  end
  
  # アレルギー情報を計算するメソッド
  def calculate_allergens(product)
    return [] unless product && product.product_menus.any?
    
    all_allergens = []
    
    # 商品に紐づくすべてのメニューをループ
    product.product_menus.includes(:menu).each do |product_menu|
      menu = product_menu.menu
      next unless menu
      
      # メニューの材料をループ
      menu.menu_materials.includes(:material).each do |menu_material|
        material = menu_material.material
        next unless material
        
        # 材料のアレルギー情報を取得
        material_allergens = material.material_allergies.map(&:allergen)
        all_allergens.concat(material_allergens) if material_allergens.any?
      end
    end
    
    # 重複を除去して、アレルギー情報をI18n化
    all_allergens.uniq.map do |allergen| 
      [allergen, MaterialAllergy.allergens_i18n[allergen]] 
    end
  end
  
  # 原材料表示を計算するメソッド
  def calculate_raw_materials_display(product, category_type)
    # カテゴリタイプに応じてraw_materialのカテゴリを設定
    category = case category_type
               when 'food'
                 RawMaterial.categories[:food] # カテゴリ1: 食品
               when 'additive'
                 RawMaterial.categories[:additive] # カテゴリ2: 添加物
               else
                 RawMaterial.categories[:other] # カテゴリ3: その他
               end
    
    # 商品がまだ保存されていない、またはメニューが関連付けられていない場合は空の文字列を返す
    return "" unless product && product.product_menus.any?
    
    # 原材料の使用量をカウントするハッシュ
    raw_materials_usage = {}
    
    # 商品に紐づくすべてのメニューをループ
    product.product_menus.includes(:menu).each do |product_menu|
      menu = product_menu.menu
      next unless menu
      
      # メニューの材料をループ
      menu.menu_materials.includes(:material).each do |menu_material|
        material = menu_material.material
        next unless material
        
        # 材料の原材料をループ
        material.material_raw_materials.includes(:raw_material).each do |mrm|
          raw_material = mrm.raw_material
          next unless raw_material
          
          # カテゴリーチェック
          next unless raw_material.category.present?
          
          # カテゴリの比較方法を修正（文字列とシンボルの比較を修正）
          is_match = false
          if category_type == 'food' && raw_material.category.to_s == 'food'
            is_match = true
          elsif category_type == 'additive' && raw_material.category.to_s == 'additive'
            is_match = true
          end
          
          next unless is_match
          
          # 使用量を計算（メニュー材料の使用量）
          usage = menu_material.amount_used.to_f
          
          # 既存の値に加算
          if raw_materials_usage[raw_material.id]
            raw_materials_usage[raw_material.id][:usage] += usage
          else
            raw_materials_usage[raw_material.id] = {
              name: raw_material.name,
              usage: usage
            }
          end
        end
      end
    end
    
    # 使用量の多い順にソート
    sorted_raw_materials = raw_materials_usage.values.sort_by { |rm| -rm[:usage] }
    
    # 原材料名だけを取り出し、カンマで結合
    sorted_raw_materials.map { |rm| rm[:name] }.join('、')
  end
end