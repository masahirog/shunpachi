class PdfsController < ApplicationController
  def manufacturing_instruction
    @daily_menu = DailyMenu.includes(
      daily_menu_products: [
        :product,
        { product: [:container, { product_menus: { menu: { menu_materials: :material } } }] }
      ]
    ).find(params[:daily_menu_id])
    
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "製造指示書_#{@daily_menu.date.strftime('%Y%m%d')}",
               template: "pdfs/manufacturing_instruction",
               layout: "layouts/pdf",
               formats: [:html],
               disposition: 'inline',
               encoding: "UTF-8",
               page_size: "A4",
               orientation: "Portrait",
               margin: { top: 5, bottom: 10, left: 5, right: 5 },
               footer: {
                 right: 'ページ: [page]/[topage]',
                 font_size: 8,
                 spacing: 5
               }
      end
    end
  end

  def product_recipe
    @product = Product.includes(
      :container,
      product_menus: { menu: { menu_materials: :material } }
    ).find(params[:product_id])
    
    @serving_size = params[:serving_size].to_i
    @serving_size = 1 if @serving_size <= 0
    
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "レシピ_#{@product.name}_#{@serving_size}人前",
               template: "pdfs/product_recipe",
               layout: "layouts/pdf",
               formats: [:html],
               disposition: 'inline',
               encoding: "UTF-8",
               page_size: "A4",
               orientation: "Portrait",
               margin: { top: 5, bottom: 10, left: 5, right: 5 }
      end
    end
  end

  def distribution_instruction
    @daily_menu = DailyMenu.includes(
      daily_menu_products: [
        :product, 
        { store_daily_menu_products: :store }
      ]
    ).find(params[:daily_menu_id])
    
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "積載仕分け指示書_#{@daily_menu.date.strftime('%Y%m%d')}",
               template: "pdfs/distribution_instruction",
               layout: "layouts/pdf",
               formats: [:html],
               disposition: 'inline',
               encoding: "UTF-8",
               page_size: "A4",
               orientation: "Landscape",  # 横向き
               margin: { top: 5, bottom: 10, left: 5, right: 5 },
               footer: {
                 right: 'ページ: [page]/[topage]',
                 font_size: 8,
                 spacing: 5
               }
      end
    end
  end
end