class AddPublicIdToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :public_id, :string
    add_index :products, :public_id, unique: true

    # 既存レコードにpublic_idを付与
    reversible do |dir|
      dir.up do
        Product.find_each do |product|
          product.update_column(:public_id, SecureRandom.alphanumeric(8))
        end
      end
    end
  end
end
