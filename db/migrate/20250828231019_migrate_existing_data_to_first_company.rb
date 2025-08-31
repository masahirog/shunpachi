class MigrateExistingDataToFirstCompany < ActiveRecord::Migration[7.1]
  def up
    # デフォルトの会社を作成
    default_company = Company.create!(
      name: 'デフォルト企業',
      subdomain: 'default'
    )
    
    # 既存のユーザーを最初の会社に割り当て
    User.where(company_id: nil).update_all(company_id: default_company.id)
    
    # Level1モデルの既存データを最初の会社に割り当て
    Vendor.where(company_id: nil).update_all(company_id: default_company.id)
    Store.where(company_id: nil).update_all(company_id: default_company.id) if Store.table_exists?
    DailyMenu.where(company_id: nil).update_all(company_id: default_company.id) if DailyMenu.table_exists?
    Container.where(company_id: nil).update_all(company_id: default_company.id) if Container.table_exists?
    
    puts "既存データを会社ID: #{default_company.id} (#{default_company.name}) に移行しました"
  end
  
  def down
    # ロールバック時の処理
    default_company = Company.find_by(subdomain: 'default')
    return unless default_company
    
    # 関連データをnullに戻す（開発環境用）
    User.where(company_id: default_company.id).update_all(company_id: nil)
    Vendor.where(company_id: default_company.id).update_all(company_id: nil)
    Store.where(company_id: default_company.id).update_all(company_id: nil) if Store.table_exists?
    DailyMenu.where(company_id: default_company.id).update_all(company_id: nil) if DailyMenu.table_exists?
    Container.where(company_id: default_company.id).update_all(company_id: nil) if Container.table_exists?
    
    # デフォルト会社を削除
    default_company.destroy
  end
end
