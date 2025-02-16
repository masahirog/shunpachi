この続きで以下のような設計でアプリ化したい。
順々に作成していくコードを出してもらえますか。
・以下のcontrollerやmodelは一切作っていない。
・viewはbootstrapを使用する
・viewはslim、必要な部分テンプレートなどは自動で作成する。
・accepts_nested_attributes_forの関係の部分はcocoonのgemを使って追加や削除を可能にしたいです。
・daiy_menusはsimple_calenderを使用して、indexは月のカレンダーviewにしたい。start_timeはdateのカラムを使用。

ーーー
controller：vendors
view：index,edit,new
model名：vendor
  has_many :materials
  clomun
    t.string :name, null: false
    t.string :phone
    t.string :fax
    t.string :mail
    t.text :address
    t.string :trading_person_name
    t.string :trading_person_phone
    t.string :trading_person_mail
    t.text :memo
    t.boolean :unused_flag, null: false, default: false
ーーー
controller：materials
view：index,edit,new
model名：material
belongs_to :vendor
belongs_to :food_ingredient
has_many :menu_materials, dependent: :destroy
has_many :material_allergies
accepts_nested_attributes_for :material_allergies, allow_destroy: true
has_many :material_food_additives
accepts_nested_attributes_for :material_food_additives, allow_destroy: true

clomun
  t.references :vendor
  t.references :food_ingredient
  t.string :name, null: false, unique: true
  t.string :food_label_name
  t.integer :category, null: false
  t.string :recipe_unit, null: false
  t.float :recipe_unit_price, null: false,default:0
  t.text :memo
  t.boolean :unused_flag, null: false, default: false

ーーー
controller：menus
view：index,edit,new

model名：menu
has_many :menu_materials,->{order("row_order asc") }, dependent: :destroy
accepts_nested_attributes_for :menu_materials, allow_destroy: true
has_many :product_menus, dependent: :destroy
has_many :food_ingredients, through: :menu_materials
enum category: {容器:0,温菜:1,冷菜:2,スイーツ:3}
clomun
  t.string :name, null: false
  t.integer :category, null: false
  t.text :cook_before
  t.text :cook_on_the_day
  t.float :cost_price, null: false,default:0
ーーー
controller：products
view：index,edit,new

model名：product
  has_many :product_menus,->{order("product_menus.row_order asc") }, dependent: :destroy
  accepts_nested_attributes_for :product_menus, allow_destroy: true
  has_many :daily_menu_details
  enum product_category: {}
clomun
  t.references :container
  t.string :name, null: false, unique: true
  t.string :food_label_name, null: false
  t.integer :sell_price,null:false,default:0
  t.float :cost_price, null: false,default:0
  t.integer :category,null:false
  t.text :introduction
  t.text :memo
  t.string :image
  t.text :serving_infomation
  t.text :food_label_contents
  t.float :calorie,null:false,default:0
  t.float :protein,null:false,default:0
  t.float :lipid,null:false,default:0
  t.float :carbohydrate,null:false,default:0
  t.float :salt,null:false,default:0
  t.string :how_to_save
  t.string :sales_unit_amount
  t.boolean :unused_flag, null: false, default: false
ーーー
controller：food_additives
view：index,edit,new

model名：food_additive
has_many :material_food_additives
clomun
  t.string :name, unique: true

ーーー
controller：food_ingredients
view：index,edit,new

model名：food_ingredient
has_many :materials
clomun
  t.string :name
  t.float :calorie,null:false,default:0
  t.float :protein,null:false,default:0
  t.float :lipid,null:false,default:0
  t.float :carbohydrate,null:false,default:0
  t.float :salt,null:false,default:0

ーーー
model名：menu_material
belongs_to :menu, optional: true
belongs_to :material, optional: true
enum source_group: {A:1,B:2,C:3,D:4,E:5,F:6,G:7,H:8}

clomun
  t.references :menu
  t.references :material
  t.float :amount_used,null:false,default:0
  t.string :preparation
  t.integer :row_order,null:false,default:0
  t.float :gram_quantity
  t.float :calorie,null:false,default:0
  t.float :protein,null:false,default:0
  t.float :lipid,null:false,default:0
  t.float :carbohydrate,null:false,default:0
  t.float :salt,null:false,default:0
  t.integer :source_group
ーーー
model名：product_menu
belongs_to :product, optional: true
belongs_to :menu, optional: true
clomun
  t.references :product
  t.references :menu
  t.integer :row_order,null:false,default:0

ーーー
model名：material_allergy
belongs_to :material, optional: true

clomun
  t.references :material
  t.integer :allergy
ーーー
model名：material_food_additive
belongs_to :material
belongs_to :food_additive
clomun
  t.references :material
  t.references :food_additive

ーーー
controller：daily_menus
view：index,edit,new

model名：daily_menu
has_many :daily_menu_details, dependent: :destroy
accepts_nested_attributes_for :daily_menu_details, allow_destroy: true
clomun
  t.date :date,null:false,unique: true
  t.integer :manufacturing_number,null:false,default:0
  t.integer :total_selling_price,null:false,default:0
  t.float :worktime


ーーー
model名：daily_menu_product
belongs_to :daily_menu,optional:true
belongs_to :product,optional:true
has_many :store_daily_menu_products
clomun
  t.references :daily_menu
  t.references :product
  t.integer :row_order, default: 0, null: false
  t.integer :manufacturing_number, default: 0, null: false
  t.integer :total_cost_price, default: 0, null: false
  t.integer :sell_price, default: 0, null: false
  t.index [:daily_menu_id,:product_id], unique: true


ーーー
controller：stores
view：index,edit,new

model名：store
has_many :store_daily_menu_products
colmun
  t.string :name, unique: true,null:false
  t.string :phone
  t.string :address
  t.boolean :unused_flag,default:false,null:false
ーーー
model名：store_daily_menu_product
belongs_to :daily_menu_product,optional:true
belongs_to :store,optional:true
clomun
  t.references :store
  t.references :daily_menu_product
  t.integer :number, default: 0, null: false
  t.integer :total_price, default: 0, null: false
