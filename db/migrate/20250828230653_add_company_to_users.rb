class AddCompanyToUsers < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:users, :company_id)
      add_reference :users, :company, null: true, foreign_key: true
    end
  end
end
