class AddCompanyToRawMaterialsAndFoodIngredients < ActiveRecord::Migration[7.1]
  def change
    # raw_materialsテーブルにcompany_id追加（NULL許可）
    add_reference :raw_materials, :company, null: true, foreign_key: true
    
    # food_ingredientsテーブルにcompany_id追加（NULL許可）
    add_reference :food_ingredients, :company, null: true, foreign_key: true
    
    # インデックス追加（パフォーマンス向上）
    add_index :raw_materials, [:company_id, :name], name: 'index_raw_materials_on_company_and_name'
    add_index :food_ingredients, [:company_id, :name], name: 'index_food_ingredients_on_company_and_name'
  end
end
