class FoodAdditivesController < ApplicationController
  before_action :set_food_additive, only: %i[edit update destroy]

  def index
    @food_additives = FoodAdditive.all
  end

  def new
    @food_additive = FoodAdditive.new
  end

  def create
    @food_additive = FoodAdditive.new(food_additive_params)
    if @food_additive.save
      redirect_to food_additives_path, notice: '食品添加物を作成しました。'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @food_additive.update(food_additive_params)
      redirect_to food_additives_path, notice: '食品添加物を更新しました。'
    else
      render :edit
    end
  end

  def destroy
    @food_additive.destroy
    redirect_to food_additives_path, notice: '食品添加物を削除しました。'
  end

  private

  def set_food_additive
    @food_additive = FoodAdditive.find(params[:id])
  end

  def food_additive_params
    params.require(:food_additive).permit(:name)
  end
end
