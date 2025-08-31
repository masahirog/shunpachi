class AddCompanyToVendors < ActiveRecord::Migration[7.1]
  def change
    add_reference :vendors, :company, null: true, foreign_key: true
  end
end
