class CreateMenus < ActiveRecord::Migration[7.1]
  def change
    create_table :menus do |t|
      t.string :name, null: false
      t.integer :category, null: false
      t.text :cook_before
      t.text :cook_on_the_day
      t.float :cost_price, null: false, default: 0

      t.timestamps
    end
  end
end
