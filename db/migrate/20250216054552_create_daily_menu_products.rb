class CreateDailyMenuProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :daily_menu_products do |t|
      t.references :daily_menu
      t.references :product
      t.integer :row_order, default: 0, null: false
      t.integer :manufacturing_number, default: 0, null: false
      t.integer :total_cost_price, default: 0, null: false
      t.integer :sell_price, default: 0, null: false
      t.index [:daily_menu_id, :product_id], unique: true
      t.timestamps
      t.integer :store_daily_menu_products_count, default: 0, null: false
    end
  end
end
