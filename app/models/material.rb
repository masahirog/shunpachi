class Material < ApplicationRecord
  belongs_to :vendor
  belongs_to :food_ingredient, optional: true

  has_many :menu_materials, dependent: :destroy
  has_many :material_allergies, dependent: :destroy

  has_many :material_raw_materials, -> { order(:position) }, dependent: :destroy
  has_many :raw_materials, through: :material_raw_materials
  
  accepts_nested_attributes_for :material_raw_materials, allow_destroy: true

  validates :name, presence: true, uniqueness: { scope: :vendor_id }
  validates :recipe_unit_gram_quantity, presence: true, numericality: { greater_than: 0 }

  # 削除制限
  before_destroy :check_usage

  def in_use?
    menu_materials.exists?
  end

  def usage_count
    menu_materials.count
  end

  private

  def check_usage
    if in_use?
      errors.add(:base, "この材料は#{usage_count}件のメニューで使用されているため削除できません")
      throw(:abort)
    end
  end

  enum recipe_unit: {gram:1,ml:2,pack:3,hon:4,ko:5,mai:6}
  enum category: {food:1,packed:2,other:3}


  def raw_materials_display
    material_raw_materials.includes(:raw_material).order(:position).map do |mrm|
      mrm.raw_material.display_name
    end.join('、')
  end
end
