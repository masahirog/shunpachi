class ProductsController < ApplicationController
  before_action :set_product, only: %i[edit update destroy show]

  def index
    @products = Product.includes(:container).all
    
    if params[:query].present?
      @products = @products.where("name LIKE ? OR food_label_name LIKE ?", "%#{params[:query]}%", "%#{params[:query]}%")
    end
    
    if params[:category].present?
      @products = @products.where(category: params[:category])
    end
    
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
        @product = Product.find(params[:id])
        if params[:product] && params[:product][:product_menus_attributes]
          @product.assign_attributes(product_params.slice(:product_menus_attributes))
        end
      else
        @product = Product.new(product_params)
      end
      
      food_contents = calculate_raw_materials_display(@product, 'food')
      additive_contents = calculate_raw_materials_display(@product, 'additive')
      
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
        @product = Product.find(params[:id])
      else
        @product = Product.new(product_params)
      end
      
      food_contents = calculate_raw_materials_display(@product, 'food')
      additive_contents = calculate_raw_materials_display(@product, 'additive')
      
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

  def show
    @product = Product.includes(
      :container,
      product_menus: { menu: { menu_materials: :material } }
    ).find(params[:id])
    
    respond_to do |format|
      format.html
      format.csv do
        # ファイル名に日本語を使わない（文字化け防止）
        filename = "product_#{@product.id}_#{Date.today.strftime('%Y%m%d')}.csv"
        
        # BOM付きUTF-8で送信（最新のExcelは対応）
        send_data product_to_csv(@product), 
                  filename: filename,
                  type: 'text/csv; charset=UTF-8'
      end
    end
  end

  private

  def product_to_csv(product)
    require 'csv'
    
    # BOM（Byte Order Mark）を付与
    bom = "\uFEFF"
    
    csv_string = CSV.generate(bom, encoding: 'UTF-8', row_sep: "\r\n", force_quotes: true) do |csv|
      # ヘッダー行
      csv << [
        "呼出しNo.",
        "呼出し名",
        "検索用呼出し名",
        "レイアウト指定",
        "品名",
        "日時1",
        "消費期限時間",
        "バーコード1",
        "税抜価格",
        "原材料",
        "保存方法内容",
        "内容量",
        "原産地",
        "製造所",
        "製造所住所",
        "熱量",
        "たんぱく質",
        "脂質",
        "炭水化物",
        "食塩相当量"
      ]
      
      # データ行
      raw_materials_parts = []
      raw_materials_parts << product.raw_materials_food_contents if product.raw_materials_food_contents.present?
      raw_materials_parts << product.raw_materials_additive_contents if product.raw_materials_additive_contents.present?
      raw_materials_combined = raw_materials_parts.join("/")
      
      csv << [
        product.label_call_number || "",
        product.name || "",
        "", # 検索用呼出し名
        "", # レイアウト指定
        product.food_label_name || "",
        "1", # 日時1
        "18時", # 消費期限時間
        product.jancode || "",
        product.sell_price || "",
        raw_materials_combined,
        product.how_to_save || "",
        product.sales_unit_amount || "",
        "", # 原産地
        "", # 製造所
        "", # 製造所住所
        "#{product.calorie} kcal",
        "#{product.protein} g",
        "#{product.lipid} g",
        "#{product.carbohydrate} g",
        "#{product.salt} g"
      ]
    end
    
    csv_string
  end

  # 数値フォーマット用のヘルパーメソッド（既にApplicationHelperにある場合は不要）
  def format_number(number)
    return "" if number.nil?
    number.to_f == number.to_i ? number.to_i.to_s : number.to_s
  end

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :food_label_name, :sell_price, :cost_price, :category, :container_id, 
    :introduction, :memo, :image, :serving_infomation, :raw_materials_food_contents, 
    :raw_materials_additive_contents, :calorie, :protein, :lipid, :carbohydrate, :salt, 
    :how_to_save, :sales_unit_amount, :unused_flag,:jancode,:label_call_number,
    product_menus_attributes: [:id, :menu_id, :product_id, :row_order, :_destroy])
  end
  
  def calculate_allergens(product)
    all_allergens = []
    
    if product.persisted?
      product.product_menus.includes(:menu).each do |product_menu|
        next unless product_menu.menu
        collect_allergens_from_menu(product_menu.menu, all_allergens)
      end
    end
    
    if params[:product] && params[:product][:product_menus_attributes]
      params[:product][:product_menus_attributes].each do |_key, menu_attrs|
        next if menu_attrs[:_destroy] == "1" || menu_attrs[:menu_id].blank?
        
        menu = Menu.find_by(id: menu_attrs[:menu_id])
        next unless menu
        
        collect_allergens_from_menu(menu, all_allergens)
      end
    end
    
    all_allergens.uniq.map do |allergen| 
      [allergen, MaterialAllergy.allergens_i18n[allergen]] 
    end
  end

  def collect_allergens_from_menu(menu, allergens_array)
    menu.menu_materials.includes(:material).each do |menu_material|
      material = menu_material.material
      next unless material
      
      material_allergens = material.material_allergies.map(&:allergen)
      allergens_array.concat(material_allergens) if material_allergens.any?
    end
  end

  def calculate_raw_materials_display(product, category_type)
    category = case category_type
                when 'food'
                when 'additive'
                else
                end
    
    raw_materials_usage = {}
    
    if product.persisted? && product.product_menus.any?
      collect_raw_materials(product.product_menus, raw_materials_usage, category_type)
    end
    
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
    
    sorted_raw_materials = raw_materials_usage.values.sort_by { |rm| -rm[:usage] }
    
    sorted_raw_materials.map { |rm| rm[:name] }.join('、')
  end

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
          
          is_match = false
          if category_type == 'food' && raw_material.category.to_s == 'food'
            is_match = true
          elsif category_type == 'additive' && raw_material.category.to_s == 'additive'
            is_match = true
          end
          
          next unless is_match
          
          usage = menu_material.amount_used.to_f
          
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