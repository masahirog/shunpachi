class CreateDailyMenus < ActiveRecord::Migration[7.1]
  def change
    create_table :daily_menus do |t|
      t.date :date, null: false
      t.integer :manufacturing_number, null: false, default: 0
      t.integer :total_selling_price, null: false, default: 0
      t.float :worktime

      t.timestamps
    end
    add_index :daily_menus, :date, unique: true
  end
end
