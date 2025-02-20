class CreateFoodIngredients < ActiveRecord::Migration[7.1]
  def change
    create_table :food_ingredients do |t|
      t.string :name
      t.float :calorie, null: false, default: 0
      t.float :protein, null: false, default: 0
      t.float :lipid, null: false, default: 0
      t.float :carbohydrate, null: false, default: 0
      t.float :salt, null: false, default: 0
      t.text :memo
      t.timestamps
    end
  end
end
