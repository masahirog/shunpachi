class CreateVendors < ActiveRecord::Migration[7.1]
  def change
    create_table :vendors do |t|
      t.string :name, null: false
      t.string :phone
      t.string :fax
      t.string :mail
      t.text :address
      t.string :trading_person_name
      t.string :trading_person_phone
      t.string :trading_person_mail
      t.text :memo
      t.boolean :unused_flag, null: false, default: false

      t.timestamps
    end
  end
end
