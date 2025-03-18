class CreateMenus < ActiveRecord::Migration[7.1]
  def change
    create_table :menus do |t|
      t.string :name, null: false
      t.integer :category, null: false
      t.text :cook_before
      t.text :cook_on_the_day
      t.float :cost_price, null: false, default: 0
      t.float :calorie, null: false, default: 0
      t.float :protein, null: false, default: 0
      t.float :lipid, null: false, default: 0
      t.float :carbohydrate, null: false, default: 0
      t.float :salt, null: false, default: 0
      t.timestamps
      t.integer :product_menus_count, default: 0, null: false
      t.integer :menu_materials_count, default: 0, null: false
    end
  end
end