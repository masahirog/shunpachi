class CreateMaterialRawMaterials < ActiveRecord::Migration[7.1]
  def change
    create_table :material_raw_materials do |t|
      t.references :material, null: false, foreign_key: true
      t.references :raw_material, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
    add_index :material_raw_materials, [:material_id, :raw_material_id], unique: true

  end
end
