class ChangeRawMaterialCategoryToNotNull < ActiveRecord::Migration[7.1]
  def up
    # 既存のNULLデータをデフォルト値で更新
    RawMaterial.where(category: nil).update_all(category: 3) # other = 3

    # categoryカラムをnull: falseに変更
    change_column_null :raw_materials, :category, false
  end

  def down
    # null: trueに戻す
    change_column_null :raw_materials, :category, true
  end
end
