class FixUniqueIndexesForMultitenant < ActiveRecord::Migration[7.1]
  def change
    # Materialテーブルの古いuniqueインデックスを削除
    remove_index :materials, name: "index_materials_on_name" if index_exists?(:materials, :name, name: "index_materials_on_name")
    
    # 正しいcompany分離対応の複合uniqueインデックスを追加
    # Materialは vendor_id でcompany分離されているため、vendor_id + name の組み合わせでunique制約
    add_index :materials, [:vendor_id, :name], unique: true, name: "index_materials_on_vendor_id_and_name"
  end
end
