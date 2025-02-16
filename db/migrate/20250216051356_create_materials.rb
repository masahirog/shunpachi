class CreateMaterials < ActiveRecord::Migration[7.1]
  def change
    create_table :materials do |t|
      t.references :vendor
      t.references :food_ingredient
      t.string :name, null: false
      t.string :food_label_name
      t.integer :category, null: false
      t.string :recipe_unit, null: false
      t.float :recipe_unit_price, null: false, default: 0
      t.text :memo
      t.boolean :unused_flag, null: false, default: false
      t.timestamps
    end
    add_index :materials, :name, unique: true
  end
end
