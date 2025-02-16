class CreateProductMenus < ActiveRecord::Migration[7.1]
  def change
    create_table :product_menus do |t|
      t.references :product
      t.references :menu
      t.integer :row_order, null: false, default: 0

      t.timestamps
    end
  end
end
