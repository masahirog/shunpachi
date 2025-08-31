# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_08_31_033405) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "companies", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "subdomain", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "containers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.integer "products_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.index ["company_id"], name: "index_containers_on_company_id"
    t.index ["name"], name: "index_containers_on_name", unique: true
  end

  create_table "daily_menu_products", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "daily_menu_id"
    t.bigint "product_id"
    t.integer "row_order", default: 0, null: false
    t.integer "manufacturing_number", default: 0, null: false
    t.integer "total_cost_price", default: 0, null: false
    t.integer "sell_price", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "store_daily_menu_products_count", default: 0, null: false
    t.index ["daily_menu_id", "product_id"], name: "index_daily_menu_products_on_daily_menu_id_and_product_id", unique: true
    t.index ["daily_menu_id"], name: "index_daily_menu_products_on_daily_menu_id"
    t.index ["product_id"], name: "index_daily_menu_products_on_product_id"
  end

  create_table "daily_menus", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "date", null: false
    t.integer "manufacturing_number", default: 0, null: false
    t.integer "total_selling_price", default: 0, null: false
    t.integer "total_cost_price", default: 0, null: false
    t.float "worktime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "daily_menu_products_count", default: 0, null: false
    t.bigint "company_id"
    t.index ["company_id"], name: "index_daily_menus_on_company_id"
    t.index ["date"], name: "index_daily_menus_on_date", unique: true
  end

  create_table "food_ingredients", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.float "calorie", default: 0.0, null: false
    t.float "protein", default: 0.0, null: false
    t.float "lipid", default: 0.0, null: false
    t.float "carbohydrate", default: 0.0, null: false
    t.float "salt", default: 0.0, null: false
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.index ["company_id", "name"], name: "index_food_ingredients_on_company_and_name"
    t.index ["company_id"], name: "index_food_ingredients_on_company_id"
  end

  create_table "material_allergies", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "material_id"
    t.integer "allergen"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["material_id"], name: "index_material_allergies_on_material_id"
  end

  create_table "material_raw_materials", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "material_id", null: false
    t.bigint "raw_material_id", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["material_id", "raw_material_id"], name: "idx_on_material_id_raw_material_id_6fc0de680e", unique: true
    t.index ["material_id"], name: "index_material_raw_materials_on_material_id"
    t.index ["raw_material_id"], name: "index_material_raw_materials_on_raw_material_id"
  end

  create_table "materials", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "vendor_id"
    t.bigint "food_ingredient_id"
    t.string "name", null: false
    t.integer "category", null: false
    t.integer "recipe_unit", null: false
    t.float "recipe_unit_price", default: 0.0, null: false
    t.text "memo"
    t.boolean "unused_flag", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "recipe_unit_gram_quantity"
    t.index ["food_ingredient_id"], name: "index_materials_on_food_ingredient_id"
    t.index ["vendor_id", "name"], name: "index_materials_on_vendor_id_and_name", unique: true
    t.index ["vendor_id"], name: "index_materials_on_vendor_id"
  end

  create_table "menu_materials", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "menu_id"
    t.bigint "material_id"
    t.float "amount_used", default: 0.0, null: false
    t.string "preparation"
    t.integer "row_order", default: 0, null: false
    t.float "gram_quantity"
    t.float "calorie", default: 0.0, null: false
    t.float "protein", default: 0.0, null: false
    t.float "lipid", default: 0.0, null: false
    t.float "carbohydrate", default: 0.0, null: false
    t.float "salt", default: 0.0, null: false
    t.integer "source_group"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "cost_price", default: 0.0, null: false
    t.index ["material_id"], name: "index_menu_materials_on_material_id"
    t.index ["menu_id"], name: "index_menu_materials_on_menu_id"
  end

  create_table "menus", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.integer "category", null: false
    t.text "cook_before"
    t.text "cook_on_the_day"
    t.float "cost_price", default: 0.0, null: false
    t.float "calorie", default: 0.0, null: false
    t.float "protein", default: 0.0, null: false
    t.float "lipid", default: 0.0, null: false
    t.float "carbohydrate", default: 0.0, null: false
    t.float "salt", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "product_menus_count", default: 0, null: false
    t.integer "menu_materials_count", default: 0, null: false
    t.bigint "company_id", null: false
    t.index ["company_id"], name: "index_menus_on_company_id"
  end

  create_table "product_menus", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "menu_id"
    t.integer "row_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_id"], name: "index_product_menus_on_menu_id"
    t.index ["product_id"], name: "index_product_menus_on_product_id"
  end

  create_table "products", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "container_id"
    t.string "name", null: false
    t.string "food_label_name", null: false
    t.integer "sell_price", default: 0, null: false
    t.float "cost_price", default: 0.0, null: false
    t.integer "category", null: false
    t.text "introduction"
    t.text "memo"
    t.text "serving_infomation"
    t.text "raw_materials_food_contents"
    t.text "raw_materials_additive_contents"
    t.float "calorie", default: 0.0, null: false
    t.float "protein", default: 0.0, null: false
    t.float "lipid", default: 0.0, null: false
    t.float "carbohydrate", default: 0.0, null: false
    t.float "salt", default: 0.0, null: false
    t.string "how_to_save"
    t.string "sales_unit_amount"
    t.boolean "unused_flag", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "daily_menu_products_count", default: 0, null: false
    t.integer "product_menus_count", default: 0, null: false
    t.string "jancode"
    t.integer "label_call_number"
    t.bigint "company_id", null: false
    t.index ["company_id"], name: "index_products_on_company_id"
    t.index ["container_id"], name: "index_products_on_container_id"
    t.index ["name"], name: "index_products_on_name", unique: true
  end

  create_table "raw_materials", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "category"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.index ["company_id", "name"], name: "index_raw_materials_on_company_and_name"
    t.index ["company_id"], name: "index_raw_materials_on_company_id"
    t.index ["name"], name: "index_raw_materials_on_name", unique: true
  end

  create_table "store_daily_menu_products", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "store_id"
    t.bigint "daily_menu_product_id"
    t.integer "number", default: 0, null: false
    t.integer "total_price", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["daily_menu_product_id"], name: "index_store_daily_menu_products_on_daily_menu_product_id"
    t.index ["store_id"], name: "index_store_daily_menu_products_on_store_id"
  end

  create_table "stores", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "phone"
    t.string "address"
    t.boolean "unused_flag", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "store_daily_menu_products_count", default: 0, null: false
    t.bigint "company_id"
    t.index ["company_id"], name: "index_stores_on_company_id"
    t.index ["name"], name: "index_stores_on_name", unique: true
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vendors", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "phone"
    t.string "fax"
    t.string "mail"
    t.text "address"
    t.string "trading_person_name"
    t.string "trading_person_phone"
    t.string "trading_person_mail"
    t.text "memo"
    t.boolean "unused_flag", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.index ["company_id"], name: "index_vendors_on_company_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "containers", "companies"
  add_foreign_key "daily_menus", "companies"
  add_foreign_key "food_ingredients", "companies"
  add_foreign_key "material_raw_materials", "materials"
  add_foreign_key "material_raw_materials", "raw_materials"
  add_foreign_key "menus", "companies"
  add_foreign_key "products", "companies"
  add_foreign_key "raw_materials", "companies"
  add_foreign_key "stores", "companies"
  add_foreign_key "users", "companies"
  add_foreign_key "vendors", "companies"
end
