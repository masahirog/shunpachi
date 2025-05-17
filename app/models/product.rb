class Product < ApplicationRecord
  has_many :product_menus, -> { order(:row_order) }, dependent: :destroy
  accepts_nested_attributes_for :product_menus, allow_destroy: true
  has_many :daily_menu_products
  has_one_attached :image  # Active Storageの設定

  enum category: { souzai: 0, bento: 1, hankanhin: 2 }
  
  validates :name, presence: true, uniqueness: true
  validates :food_label_name, presence: true
  validates :sell_price, :cost_price, numericality: { greater_than_or_equal_to: 0 }
  
  # 画像のバリデーション
  validate :acceptable_image
  
  private
  
  def acceptable_image
    return unless image.attached?
    
    # 画像サイズのバリデーション
    unless image.blob.byte_size <= 5.megabyte
      errors.add(:image, 'は5MB以下にしてください')
    end
    
    # 画像フォーマットのバリデーション
    acceptable_types = ['image/jpeg', 'image/png', 'image/gif']
    unless acceptable_types.include?(image.blob.content_type)
      errors.add(:image, 'はJPEG、PNG、GIF形式でアップロードしてください')
    end
  end
end