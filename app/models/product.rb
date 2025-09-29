class Product < ApplicationRecord
  include TenantScoped

  has_many :product_menus, -> { order(:row_order) }, dependent: :destroy
  accepts_nested_attributes_for :product_menus, allow_destroy: true
  has_many :daily_menu_products
  has_one_attached :image  # Active Storageの設定


  enum category: { souzai: 0, bento: 1, hankanhin: 2 }

  validates :name, presence: true, uniqueness: { scope: :company_id }
  validates :food_label_name, presence: true
  validates :sell_price, :cost_price, numericality: { greater_than_or_equal_to: 0 }

  # public_idの自動生成
  before_create :generate_public_id

  # 削除制限
  before_destroy :check_usage

  def in_use?
    daily_menu_products.exists?
  end

  def usage_count
    daily_menu_products.count
  end
  
  # 画像のバリデーション
  validate :acceptable_image
  
  # 既存レコードにpublic_idを生成するクラスメソッド
  def self.generate_missing_public_ids
    where(public_id: nil).find_each do |product|
      product.update_column(:public_id, SecureRandom.alphanumeric(8))
    end
  end

  private

  def check_usage
    if in_use?
      errors.add(:base, "この商品は#{usage_count}件の日次献立で使用されているため削除できません")
      throw(:abort)
    end
  end

  def generate_public_id
    self.public_id = SecureRandom.alphanumeric(8) if public_id.blank?
  end

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