class AddPercentageToMaterialRawMaterials < ActiveRecord::Migration[7.1]
  def change
    add_column :material_raw_materials, :percentage, :decimal, precision: 5, scale: 2, default: 0.0
  end
end
