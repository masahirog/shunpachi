class ChangePercentageToIntegerInMaterialRawMaterials < ActiveRecord::Migration[7.1]
  def change
    change_column :material_raw_materials, :percentage, :integer, default: 0
  end
end
