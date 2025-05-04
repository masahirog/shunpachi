class MaterialAllergy < ApplicationRecord
  belongs_to :material, optional: true
  enum allergen: {shrimp: 0,crab: 1,walnut: 2,wheat: 3,buckwheat: 4,egg: 5,milk: 6,peanut: 7}

end
