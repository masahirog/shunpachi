class ProductsController < ApplicationController
  before_action :set_product, only: %i[edit update destroy]

  def index
    @products = Product.all
    
    # 検索機能
    if params[:query].present?
      @products = @products.where("name LIKE ? OR food_label_name LIKE ?", "%#{params[:query]}%", "%#{params[:query]}%")
    end
    
    # カテゴリフィルター
    if params[:category].present?
      @products = @products.where(category: params[:category])
    end
    
    # 新しいものを上に表示
    @products = @products.order(id: :desc).paginate(page: params[:page], per_page: 30)
  end

  def new
    @product = Product.new
    @menus = Menu.select(:id, :name, :category, :cost_price).order(:name)
  end

  def edit
    @product = Product.includes(product_menus: :menu).find(params[:id])
    @menus = Menu.select(:id, :name, :category, :cost_price).order(:name)
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to products_path, notice: '商品を作成しました。'
    else
      render :new
    end
  end

  def update
    # 画像削除パラメータの処理
    if params[:product][:remove_image] == '1' && @product.image.attached?
      @product.image.purge
    end
    
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


  def generate_raw_materials
    begin
      Rails.logger.debug("原材料表示生成 - パラメータ: #{params.inspect}")
      
      if params[:id].present?
        # 既存の商品の場合
        @product = Product.find(params[:id])
        # メニュー情報も更新
        if params[:product] && params[:product][:product_menus_attributes]
          # 既存のメニューデータで一時的に更新
          @product.assign_attributes(product_params.slice(:product_menus_attributes))
        end
      else
        # 新規作成の場合
        @product = Product.new(product_params)
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
    rescue => e
      Rails.logger.error("原材料表示の生成中にエラーが発生しました: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      
      render json: { error: e.message }, status: :internal_server_error
    end
  end


  def generate_raw_materials_display
    begin
      if params[:id].present?
        # 既存の商品の場合（memberアクション）
        @product = Product.find(params[:id])
      else
        # 新規作成の場合
        @product = Product.new(product_params)
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
    rescue => e
      Rails.logger.error("原材料表示の生成中にエラーが発生しました: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      
      render json: { error: e.message }, status: :internal_server_error
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :food_label_name, :sell_price, :cost_price, :category, :container_id, 
    :introduction, :memo, :image, :serving_infomation, :raw_materials_food_contents, 
    :raw_materials_additive_contents, :calorie, :protein, :lipid, :carbohydrate, :salt, 
    :how_to_save, :sales_unit_amount, :unused_flag,
    product_menus_attributes: [:id, :menu_id, :product_id, :row_order, :_destroy])
  end
  
  # calculate_allergens メソッドを修正して、未保存のメニューも処理できるようにする
  def calculate_allergens(product)
    all_allergens = []
    
    # 永続化されたメニュー
    if product.persisted?
      product.product_menus.includes(:menu).each do |product_menu|
        next unless product_menu.menu
        collect_allergens_from_menu(product_menu.menu, all_allergens)
      end
    end
    
    # 新規追加されたメニュー（未保存）
    if params[:product] && params[:product][:product_menus_attributes]
      params[:product][:product_menus_attributes].each do |_key, menu_attrs|
        next if menu_attrs[:_destroy] == "1" || menu_attrs[:menu_id].blank?
        
        menu = Menu.find_by(id: menu_attrs[:menu_id])
        next unless menu
        
        collect_allergens_from_menu(menu, all_allergens)
      end
    end
    
    # 重複を除去して、アレルギー情報をI18n化
    all_allergens.uniq.map do |allergen| 
      [allergen, MaterialAllergy.allergens_i18n[allergen]] 
    end
  end

  # メニューからアレルギー情報を収集するヘルパーメソッド
  def collect_allergens_from_menu(menu, allergens_array)
    menu.menu_materials.includes(:material).each do |menu_material|
      material = menu_material.material
      next unless material
      
      material_allergens = material.material_allergies.map(&:allergen)
      allergens_array.concat(material_allergens) if material_allergens.any?
    end
  end

  # calculate_raw_materials_display メソッドも同様に修正
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
    
    raw_materials_usage = {}
    
    # 1. 永続化されたメニューを処理
    if product.persisted? && product.product_menus.any?
      collect_raw_materials(product.product_menus, raw_materials_usage, category_type)
    end
    
    # 2. 新規追加されたメニュー（未保存）を処理
    if params[:product] && params[:product][:product_menus_attributes]
      temp_product_menus = []
      
      params[:product][:product_menus_attributes].each do |_key, menu_attrs|
        next if menu_attrs[:_destroy] == "1" || menu_attrs[:menu_id].blank?
        
        menu = Menu.find_by(id: menu_attrs[:menu_id])
        next unless menu
        
        temp_product_menus << OpenStruct.new(menu: menu)
      end
      
      collect_raw_materials(temp_product_menus, raw_materials_usage, category_type)
    end
    
    # 使用量の多い順にソート
    sorted_raw_materials = raw_materials_usage.values.sort_by { |rm| -rm[:usage] }
    
    # 原材料名だけを取り出し、カンマで結合
    sorted_raw_materials.map { |rm| rm[:name] }.join('、')
  end

  # 原材料の収集を行うヘルパーメソッド
  def collect_raw_materials(product_menus, raw_materials_usage, category_type)
    product_menus.each do |product_menu|
      menu = product_menu.is_a?(ProductMenu) ? product_menu.menu : product_menu.menu
      next unless menu
      
      menu.menu_materials.includes(:material).each do |menu_material|
        material = menu_material.material
        next unless material
        
        material.material_raw_materials.includes(:raw_material).each do |mrm|
          raw_material = mrm.raw_material
          next unless raw_material && raw_material.category.present?
          
          # カテゴリの比較
          is_match = false
          if category_type == 'food' && raw_material.category.to_s == 'food'
            is_match = true
          elsif category_type == 'additive' && raw_material.category.to_s == 'additive'
            is_match = true
          end
          
          next unless is_match
          
          # 使用量を計算
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
  end
end