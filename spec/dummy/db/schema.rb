# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171226223917) do

  create_table "coin_payment_transactions", force: :cascade do |t|
    t.integer "estimated_value", limit: 8
    t.string "transaction_hash"
    t.string "block_hash"
    t.datetime "block_time"
    t.datetime "estimated_time"
    t.integer "coin_payment_id"
    t.integer "coin_conversion", limit: 8
    t.integer "confirmations"
    t.index ["coin_payment_id"], name: "index_coin_payment_transactions_on_coin_payment_id"
  end

  create_table "coin_payments", force: :cascade do |t|
    t.string "payable_type"
    t.integer "coin_type"
    t.integer "payable_id"
    t.string "currency"
    t.string "reason"
    t.integer "price", limit: 8
    t.integer "coin_amount_due", limit: 8, default: 0
    t.string "address"
    t.string "state", default: "pending"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "coin_conversion", limit: 8
    t.index ["payable_type", "payable_id"], name: "index_coin_payments_on_payable_type_and_payable_id"
  end

  create_table "currency_conversions", force: :cascade do |t|
    t.integer "currency"
    t.integer "price", limit: 8
    t.integer "coin_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "widgets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
