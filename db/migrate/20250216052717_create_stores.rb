class CreateStores < ActiveRecord::Migration[7.1]
  def change
    create_table :stores do |t|
      t.string :name, null: false
      t.string :phone
      t.string :address
      t.boolean :unused_flag, null: false, default: false

      t.timestamps
    end
    add_index :stores, :name, unique: true
  end
end
