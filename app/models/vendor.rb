class Vendor < ApplicationRecord
  has_many :materials, dependent: :destroy

  validates :name, presence: true
end
