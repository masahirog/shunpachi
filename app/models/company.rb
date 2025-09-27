class Company < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :vendors, dependent: :destroy
  has_many :stores, dependent: :destroy
  has_many :daily_menus, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
  validates :subdomain, presence: true, uniqueness: true, format: { with: /\A[a-z0-9\-]+\z/, message: "英数字とハイフンのみ使用可能です" }
end
