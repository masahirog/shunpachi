class CreateFoodAdditives < ActiveRecord::Migration[7.1]
  def change
    create_table :food_additives do |t|
      t.string :name
      t.timestamps
    end
    add_index :food_additives, :name, unique: true
  end
end
