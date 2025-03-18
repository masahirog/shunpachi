class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.references :container
      t.string :name, null: false
      t.string :food_label_name, null: false
      t.integer :sell_price, null: false, default: 0
      t.float :cost_price, null: false, default: 0
      t.integer :category, null: false
      t.text :introduction
      t.text :memo
      t.string :image
      t.text :serving_infomation
      t.text :food_label_contents
      t.float :calorie, null: false, default: 0
      t.float :protein, null: false, default: 0
      t.float :lipid, null: false, default: 0
      t.float :carbohydrate, null: false, default: 0
      t.float :salt, null: false, default: 0
      t.string :how_to_save
      t.string :sales_unit_amount
      t.boolean :unused_flag, null: false, default: false

      t.timestamps
      t.integer :daily_menu_products_count, default: 0, null: false
      t.integer :product_menus_count, default: 0, null: false
    end
    add_index :products, :name, unique: true
  end
end
