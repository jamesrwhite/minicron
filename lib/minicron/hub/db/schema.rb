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

  create_table "alerts", force: true do |t|
    t.integer  "job_id",                              null: false
    t.integer  "execution_id"
    t.integer  "schedule_id"
    t.string   "kind",         limit: 4, default: "", null: false
    t.datetime "expected_at"
    t.string   "medium",       limit: 9, default: "", null: false
    t.datetime "sent_at",                             null: false
  end

  add_index "alerts", ["execution_id"], name: "alerts_execution_id", using: :btree
  add_index "alerts", ["expected_at"], name: "expected_at", using: :btree
  add_index "alerts", ["job_id"], name: "alerts_job_id", using: :btree
  add_index "alerts", ["kind"], name: "kind", using: :btree
  add_index "alerts", ["medium"], name: "medium", using: :btree
  add_index "alerts", ["schedule_id"], name: "schedule_id", using: :btree

  create_table "executions", force: true do |t|
    t.integer  "job_id",      null: false
    t.integer  "number",      null: false
    t.datetime "created_at",  null: false
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer  "exit_status"
  end

  add_index "executions", ["created_at"], name: "executions_created_at", using: :btree
  add_index "executions", ["finished_at"], name: "finished_at", using: :btree
  add_index "executions", ["job_id", "number"], name: "unique_number_per_job", unique: true, using: :btree
  add_index "executions", ["job_id"], name: "executions_job_id", using: :btree
  add_index "executions", ["started_at"], name: "started_at", using: :btree

  create_table "hosts", force: true do |t|
    t.string   "name"
    t.string   "fqdn",                  default: "", null: false
    t.string   "user",       limit: 32, default: "", null: false
    t.string   "host",                  default: "", null: false
    t.integer  "port",                               null: false
    t.text     "public_key"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "hosts", ["fqdn"], name: "hostname", using: :btree

  create_table "job_execution_outputs", force: true do |t|
    t.integer  "execution_id", null: false
    t.integer  "seq",          null: false
    t.text     "output",       null: false
    t.datetime "timestamp",    null: false
  end

  add_index "job_execution_outputs", ["execution_id"], name: "job_execution_outputs_execution_id", using: :btree
  add_index "job_execution_outputs", ["seq"], name: "seq", using: :btree

  create_table "jobs", force: true do |t|
    t.integer  "host_id",                            null: false
    t.string   "job_hash",   limit: 32, default: "", null: false
    t.string   "name"
    t.string   "user",       limit: 32,              null: false
    t.text     "command",                            null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "jobs", ["created_at"], name: "jobs_created_at", using: :btree
  add_index "jobs", ["host_id"], name: "host_id", using: :btree
  add_index "jobs", ["job_hash"], name: "job_hash", unique: true, using: :btree

  create_table "schedules", force: true do |t|
    t.integer  "job_id",                       null: false
    t.string   "minute",           limit: 169
    t.string   "hour",             limit: 61
    t.string   "day_of_the_month", limit: 83
    t.string   "month",            limit: 26
    t.string   "day_of_the_week",  limit: 13
    t.string   "special",          limit: 9
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "schedules", ["day_of_the_month"], name: "day_of_the_month", using: :btree
  add_index "schedules", ["day_of_the_week"], name: "day_of_the_week", using: :btree
  add_index "schedules", ["hour"], name: "hour", using: :btree
  add_index "schedules", ["job_id"], name: "schedules_job_id", using: :btree
  add_index "schedules", ["minute"], name: "minute", using: :btree
  add_index "schedules", ["month"], name: "month", using: :btree
  add_index "schedules", ["special"], name: "special", using: :btree

end
