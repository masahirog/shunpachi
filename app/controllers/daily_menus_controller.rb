class DailyMenusController < ApplicationController
  before_action :set_daily_menu, only: %i[edit update destroy]

  def index
    @daily_menus = DailyMenu.all
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
    params.require(:daily_menu).permit(:date, :manufacturing_number, :total_selling_price, :worktime)
  end
end
