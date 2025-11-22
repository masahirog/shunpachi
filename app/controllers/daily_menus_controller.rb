# app/controllers/daily_menus_controller.rb
class DailyMenusController < ApplicationController
  before_action :set_daily_menu, only: [:edit, :update, :destroy]

  def index
    @current_month = if params[:date].present?
                       begin
                         Date.parse(params[:date]).beginning_of_month
                       rescue
                         Date.today.beginning_of_month
                       end
                     else
                       Date.today.beginning_of_month
                     end
    @calendar_data = generate_calendar_data(@current_month)
  end

  def material_schedule
    # 期間の設定（デフォルトは今週）
    @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today.beginning_of_week
    @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today.end_of_week

    # 期間内のdaily_menusを取得
    daily_menus = company_scope(DailyMenu)
                    .includes(daily_menu_products: { product: { product_menus: { menu: { menu_materials: [:material, :menu] } } } })
                    .where(date: @start_date..@end_date)
                    .order(:date)

    # 食材使用量を集計
    @material_usage = calculate_material_usage(daily_menus)

    # ベンダー別にグループ化
    @materials_by_vendor = @material_usage.group_by { |data| data[:vendor] }
                                           .sort_by { |vendor, _| vendor.name }
                                           .to_h
  end

  def new
    date = params[:date].present? ? Date.parse(params[:date]) : Date.today
    # 既に同じ日付の献立があるか確認
    existing_menu = company_scope(DailyMenu).find_by(date: date)
    
    if existing_menu
      redirect_to edit_daily_menu_path(existing_menu), notice: '既に献立が作成されています'
    else
      @daily_menu = DailyMenu.new(date: date)
      # デフォルトの製造数
      @daily_menu.manufacturing_number = 30
      @products = Product.for_company(current_company).where(unused_flag: false)
    end
  end

  def create
    @daily_menu = DailyMenu.new(daily_menu_params)
    @daily_menu.company = current_company
    
    if @daily_menu.save
      redirect_to edit_daily_menu_path(@daily_menu), notice: '献立を作成しました'
    else
      @products = Product.for_company(current_company).where(unused_flag: false)
      render :new
    end
  end

  def edit
    @products = Product.for_company(current_company).where(unused_flag: false)
  end

  def update
    if @daily_menu.update(daily_menu_params)
      # 合計金額の再計算
      update_totals(@daily_menu)
      redirect_to daily_menus_path, notice: '献立を更新しました'
    else
      @products = Product.for_company(current_company).where(unused_flag: false)
      render :edit
    end
  end

  def destroy
    @daily_menu.destroy
    redirect_to daily_menus_path, notice: '献立を削除しました'
  end
  
  private
  
  def set_daily_menu
    @daily_menu = company_scope(DailyMenu).includes(
      { daily_menu_products: [:product, store_daily_menu_products: :store] }
    ).find(params[:id])

  end
  
  def daily_menu_params
    params.require(:daily_menu).permit(:date, :manufacturing_number, :worktime,
      daily_menu_products_attributes: [:id, :product_id, :row_order, :manufacturing_number, :sell_price, :total_cost_price, :_destroy,
        store_daily_menu_products_attributes: [:id, :store_id, :number, :total_price, :_destroy]]
    )
  end

  def update_totals(daily_menu)
    # 各商品の製造数を店舗配分の合計から計算
    total_manufacturing = 0
    
    daily_menu.daily_menu_products.each do |dmp|
      total_number = dmp.store_daily_menu_products.sum(:number)
      dmp.update_column(:manufacturing_number, total_number) if total_number != dmp.manufacturing_number
      total_manufacturing += total_number
    end
    
    # 合計金額の再計算
    total_selling_price = daily_menu.daily_menu_products.sum do |dmp|
      dmp.sell_price * dmp.manufacturing_number
    end
    
    total_cost_price = daily_menu.daily_menu_products.sum do |dmp|
      dmp.total_cost_price * dmp.manufacturing_number
    end
    
    # 左上の製造数も更新
    daily_menu.update_columns(
      total_selling_price: total_selling_price,
      total_cost_price: total_cost_price,
      manufacturing_number: total_manufacturing
    )
  end


  
  def generate_calendar_data(current_month)
    # 月の開始日と終了日を取得
    start_date = current_month.beginning_of_month.beginning_of_week(:sunday)
    end_date = current_month.end_of_month.end_of_week(:sunday)

    # 日付の範囲を作成
    date_range = (start_date..end_date).to_a

    # その期間の献立データを取得（1回のクエリで効率的に）
    # N+1問題回避のためにincludes使用
    daily_menus = company_scope(DailyMenu).includes(daily_menu_products: :product)
                           .where(date: start_date..end_date)
                           .index_by(&:date)

    # カレンダーデータを生成
    date_range.map do |day|
      {
        date: day,
        daily_menu: daily_menus[day]
      }
    end
  end

  def calculate_material_usage(daily_menus)
    material_data = Hash.new do |h, material_id|
      h[material_id] = {
        material: nil,
        vendor: nil,
        total_amount: 0,
        unit: nil,
        dates: Set.new,
        daily_amounts: Hash.new(0)
      }
    end

    daily_menus.each do |daily_menu|
      daily_menu.daily_menu_products.each do |dmp|
        manufacturing_number = dmp.manufacturing_number || 0

        dmp.product.product_menus.each do |pm|
          pm.menu.menu_materials.each do |mm|
            material = mm.material
            amount_per_product = mm.amount_used || 0
            total_amount = amount_per_product * manufacturing_number

            material_data[material.id][:material] = material
            material_data[material.id][:vendor] = material.vendor
            material_data[material.id][:total_amount] += total_amount
            material_data[material.id][:unit] = material.recipe_unit_i18n
            material_data[material.id][:dates] << daily_menu.date
            material_data[material.id][:daily_amounts][daily_menu.date] += total_amount
          end
        end
      end
    end

    # Hashから配列に変換してソート
    material_data.values
                 .select { |data| data[:total_amount] > 0 }
                 .sort_by { |data| [data[:vendor]&.name || '', data[:material]&.name || ''] }
  end
end