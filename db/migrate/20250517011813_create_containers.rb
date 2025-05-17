class CreateContainers < ActiveRecord::Migration[7.1]
  def change
    create_table :containers do |t|
      t.string :name, null: false
      t.integer :products_count, null: false, default: 0

      t.timestamps
    end
    
    add_index :containers, :name, unique: true
  end
end