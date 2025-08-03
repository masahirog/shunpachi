class MenuMaterial < ApplicationRecord
  belongs_to :menu, counter_cache: true
  belongs_to :material, optional: true
  enum source_group: { A: 1, B: 2, C: 3, D: 4, E: 5, F: 6, G: 7, H: 8 }
  
  acts_as_list scope: :menu, column: :row_order
end
