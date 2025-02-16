class MenusController < ApplicationController
  before_action :set_menu, only: %i[edit update destroy]

  def index
    @menus = Menu.all
  end

  def new
    @menu = Menu.new
  end

  def create
    @menu = Menu.new(menu_params)
    if @menu.save
      redirect_to menus_path, notice: 'メニューを作成しました。'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @menu.update(menu_params)
      redirect_to menus_path, notice: 'メニューを更新しました。'
    else
      render :edit
    end
  end

  def destroy
    @menu.destroy
    redirect_to menus_path, notice: 'メニューを削除しました。'
  end

  private

  def set_menu
    @menu = Menu.find(params[:id])
  end

  def menu_params
    params.require(:menu).permit(:name, :category, :cook_before, :cook_on_the_day, :cost_price)
  end
end
