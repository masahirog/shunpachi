class AddCompanyToContainers < ActiveRecord::Migration[7.1]
  def change
    add_reference :containers, :company, null: true, foreign_key: true
  end
end
