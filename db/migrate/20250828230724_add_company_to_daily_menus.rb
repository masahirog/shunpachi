class AddCompanyToDailyMenus < ActiveRecord::Migration[7.1]
  def change
    add_reference :daily_menus, :company, null: true, foreign_key: true
  end
end
