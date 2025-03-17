class ProductsController < ApplicationController
  before_action :set_product, only: %i[edit update destroy]

  def index
    @products = Product.all
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

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :food_label_name, :sell_price, :cost_price, :category, :introduction, :memo, :image,
     :serving_infomation, :food_label_contents, :calorie, :protein, :lipid, :carbohydrate, :salt, :how_to_save, :sales_unit_amount, :unused_flag,
     product_menus_attributes: [:id,:menu_id,:product_id,:row_order,:_destroy])
  end
end
