class CreateRawMaterials < ActiveRecord::Migration[7.1]
  def change
    create_table :raw_materials do |t|
      t.string :name
      t.integer :category
      t.text :description

      t.timestamps
    end

    add_index :raw_materials, :name, unique: true
  end
end
