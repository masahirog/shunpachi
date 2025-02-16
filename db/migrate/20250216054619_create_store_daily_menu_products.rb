class CreateStoreDailyMenuProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :store_daily_menu_products do |t|
      t.references :store
      t.references :daily_menu_product
      t.integer :number, default: 0, null: false
      t.integer :total_price, default: 0, null: false

      t.timestamps
    end
  end
end
