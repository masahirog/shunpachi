class CreateRawMaterials < ActiveRecord::Migration[7.1]
  # def change
  #   create_table :raw_materials do |t|
  #     t.string :name
  #     t.integer :category
  #     t.text :description

  #     t.timestamps
  #   end

  #   add_index :raw_materials, :name, unique: true
  # end
  def down
    
    # 外部キー制約を一時的に無効にする
    execute "SET FOREIGN_KEY_CHECKS=0;"
    drop_table :raw_materials
    execute "SET FOREIGN_KEY_CHECKS=1;"
    
    # または単純にコメントアウトする場合
    # # drop_table :raw_materials
  end
end
