class DailyMenusController < ApplicationController
  before_action :set_daily_menu, only: %i[edit update destroy]

  def index
    if params[:date].present?
      @date = params[:date].to_date
    else
      @date = Date.today
    end
    params[:start_date] = @date
    @dates = ((@date.beginning_of_month - 6)..(@date.end_of_month+6)).to_a
    @daily_menus = DailyMenu.where(date:@dates)
    creare_dates = @dates - @daily_menus.map{|dm|dm.date}
    if creare_dates.present?
      new_arr = []
      creare_dates.each do |date|
        new_arr << DailyMenu.new(date:date)
      end
      DailyMenu.import new_arr
      @daily_menus = DailyMenu.where(date:@dates)
    end
  end

  def new
    @daily_menu = DailyMenu.new
  end

  def create
    @daily_menu = DailyMenu.new(daily_menu_params)
    if @daily_menu.save
      redirect_to daily_menus_path, notice: '日別メニューを作成しました。'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @daily_menu.update(daily_menu_params)
      redirect_to daily_menus_path, notice: '日別メニューを更新しました。'
    else
      render :edit
    end
  end

  def destroy
    @daily_menu.destroy
    redirect_to daily_menus_path, notice: '日別メニューを削除しました。'
  end

  private

  def set_daily_menu
    @daily_menu = DailyMenu.find(params[:id])
  end

  def daily_menu_params
    params.require(:daily_menu).permit(:date, :manufacturing_number, :total_selling_price, :worktime,:total_cost_price)
  end
end
