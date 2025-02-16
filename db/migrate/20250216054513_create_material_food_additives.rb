class CreateMaterialFoodAdditives < ActiveRecord::Migration[7.1]
  def change
    create_table :material_food_additives do |t|
      t.references :material
      t.references :food_additive

      t.timestamps
    end
  end
end
