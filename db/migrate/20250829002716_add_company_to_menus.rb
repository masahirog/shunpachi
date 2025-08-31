class AddCompanyToMenus < ActiveRecord::Migration[7.1]
  def change
    add_reference :menus, :company, null: true, foreign_key: true
    
    # 既存データにcompany_idを設定（最初の企業のIDを使用）
    reversible do |dir|
      dir.up do
        first_company = Company.first
        if first_company
          Menu.update_all(company_id: first_company.id)
        end
        
        # null制約を追加
        change_column_null :menus, :company_id, false
      end
    end
  end
end
