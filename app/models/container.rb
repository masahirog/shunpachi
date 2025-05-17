class Container < ApplicationRecord
	has_many :products, counter_cache: true
	validates :name, presence: true, uniqueness: true

end
