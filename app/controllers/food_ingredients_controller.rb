class FoodIngredientsController < ApplicationController
  before_action :set_food_ingredient, only: %i[edit update destroy]

  def search
    query = params[:q]
    food_ingredients = if query.present?
                         FoodIngredient.for_company(current_company).where("name LIKE ?", "%#{query}%")
                       else
                         FoodIngredient.none
                       end

    render json: food_ingredients.select(:id, :name) # 必要なデータのみ返す
  end

  def index
    # 検索クエリがある場合は検索結果を表示、なければ全件表示
    @query = params[:query]
    
    # スコープフィルター
    @food_ingredients = case params[:scope]
                        when 'common'
                          FoodIngredient.common
                        when 'company_only'
                          FoodIngredient.company_only(current_company)
                        else
                          FoodIngredient.for_company(current_company)
                        end
    
    # 検索機能
    if @query.present?
      @food_ingredients = @food_ingredients.where("name LIKE ?", "%#{@query}%")
    end
    
    # ページネーション
    @food_ingredients = @food_ingredients.paginate(page: params[:page], per_page: 30)
  end

  def new
    @food_ingredient = FoodIngredient.new
  end

  def create
    @food_ingredient = FoodIngredient.new(food_ingredient_params)
    @food_ingredient.company = current_company  # 自社専用として作成
    if @food_ingredient.save
      redirect_to food_ingredients_path, notice: '食品成分を作成しました。'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @food_ingredient.update(food_ingredient_params)
      redirect_to food_ingredients_path, notice: '食品成分を更新しました。'
    else
      render :edit
    end
  end

  def destroy
    @food_ingredient.destroy
    redirect_to food_ingredients_path, notice: '食品成分を削除しました。'
  end

  private

  def set_food_ingredient
    @food_ingredient = FoodIngredient.for_company(current_company).find(params[:id])
  end

  def food_ingredient_params
    params.require(:food_ingredient).permit(:name, :calorie, :protein, :lipid, :carbohydrate, :salt)
  end
end