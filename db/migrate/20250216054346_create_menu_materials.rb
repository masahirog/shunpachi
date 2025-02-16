class CreateMenuMaterials < ActiveRecord::Migration[7.1]
  def change
    create_table :menu_materials do |t|
      t.references :menu
      t.references :material
      t.float :amount_used, null: false, default: 0
      t.string :preparation
      t.integer :row_order, null: false, default: 0
      t.float :gram_quantity
      t.float :calorie, null: false, default: 0
      t.float :protein, null: false, default: 0
      t.float :lipid, null: false, default: 0
      t.float :carbohydrate, null: false, default: 0
      t.float :salt, null: false, default: 0
      t.integer :source_group

      t.timestamps
    end
  end
end
