class PublicProductsController < ApplicationController
  skip_before_action :authenticate_user!
  layout 'public'

  def show
    @product = Product.find_by!(public_id: params[:public_id])

    # OGP用の画像URL設定
    if @product.image.attached?
      @og_image_url = url_for(@product.image)
    end

    # 画像をActiveStorageから読み込む
    @product_menus = @product.product_menus.includes(
      menu: {
        menu_materials: {
          material: :material_allergies
        }
      }
    )

    # アレルギー情報の収集
    @allergens = []
    @product_menus.each do |pm|
      next unless pm.menu
      pm.menu.menu_materials.each do |mm|
        next unless mm.material
        mm.material.material_allergies.each do |ma|
          @allergens << ma.allergen if ma.allergen.present?
        end
      end
    end
    @allergens = @allergens.uniq
  rescue ActiveRecord::RecordNotFound
    render file: "#{Rails.root}/public/404.html", layout: false, status: 404
  end
end