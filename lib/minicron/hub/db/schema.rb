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

ActiveRecord::Schema.define(version: 0) do

  create_table "executions", force: true do |t|
    t.integer  "job_id",      null: false
    t.datetime "created_at",  null: false
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer  "exit_status"
    t.index ["created_at"], :name => "created_at"
    t.index ["finished_at"], :name => "finished_at"
    t.index ["job_id"], :name => "job_id"
    t.index ["started_at"], :name => "started_at"
  end

  create_table "hosts", force: true do |t|
    t.string   "name"
    t.string   "fqdn",       default: "", null: false
    t.string   "host",       default: "", null: false
    t.integer  "port",       default: 22, null: false
    t.text     "public_key"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["fqdn"], :name => "hostname"
  end

  create_table "job_execution_outputs", force: true do |t|
    t.integer  "execution_id", null: false
    t.integer  "seq",          null: false
    t.text     "output",       null: false
    t.datetime "timestamp",    null: false
    t.index ["execution_id"], :name => "execution_id"
    t.index ["seq"], :name => "seq"
  end

  create_table "jobs", force: true do |t|
    t.string   "job_hash",   limit: 32, default: "", null: false
    t.string   "name"
    t.text     "command",                            null: false
    t.integer  "host_id",                            null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.index ["created_at"], :name => "created_at"
    t.index ["host_id"], :name => "host_id"
    t.index ["job_hash"], :name => "job_hash", :unique => true
  end

  create_table "schedules", force: true do |t|
    t.integer  "job_id",                       null: false
    t.string   "minute",           limit: 179
    t.string   "hour",             limit: 71
    t.string   "day_of_the_month", limit: 92
    t.string   "month",            limit: 25
    t.string   "day_of_the_week",  limit: 20
    t.string   "special",          limit: 9
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["day_of_the_month"], :name => "day_of_the_month"
    t.index ["day_of_the_week"], :name => "day_of_the_week"
    t.index ["hour"], :name => "hour"
    t.index ["job_id"], :name => "job_id"
    t.index ["minute"], :name => "minute"
    t.index ["month"], :name => "month"
    t.index ["special"], :name => "special"
  end

end
