class CreateMaterialAllergies < ActiveRecord::Migration[7.1]
  def change
    create_table :material_allergies do |t|
      t.references :material
      t.integer :allergen

      t.timestamps
    end
  end
end
