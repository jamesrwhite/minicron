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

ActiveRecord::Schema.define(version: 20170613172214) do

  create_table "alerts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id",                             null: false
    t.integer  "job_id",                              null: false
    t.integer  "execution_id"
    t.integer  "schedule_id"
    t.string   "kind",         limit: 4, default: "", null: false
    t.datetime "expected_at"
    t.string   "medium",       limit: 9, default: "", null: false
    t.datetime "sent_at",                             null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["user_id"], name: "user_id", using: :btree
    t.index ["execution_id"], name: "execution_id", using: :btree
    t.index ["expected_at"], name: "expected_at", using: :btree
    t.index ["job_id"], name: "job_id", using: :btree
    t.index ["kind"], name: "kind", using: :btree
    t.index ["medium"], name: "medium", using: :btree
    t.index ["schedule_id"], name: "schedule_id", using: :btree
  end

  create_table "executions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id",     null: false
    t.integer  "job_id",      null: false
    t.integer  "host_id",      null: false
    t.integer  "number",      null: false
    t.datetime "created_at",  null: false
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer  "exit_status"
    t.datetime "updated_at",              null: false
    t.index ["user_id"], name: "user_id", using: :btree
    t.index ["job_id"], name: "job_id", using: :btree
    t.index ["host_id"], name: "host_id", using: :btree
    t.index ["created_at"], name: "created_at", using: :btree
    t.index ["started_at"], name: "started_at", using: :btree
    t.index ["finished_at"], name: "finished_at", using: :btree
    t.index ["user_id", "job_id", "number"], name: "unique_number_per_user_per_job", unique: true, using: :btree
  end

  create_table "hosts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id",                 null: false
    t.string   "name"
    t.string   "hostname",   default: "", null: false
    t.integer  "executions_count",               default: 0
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["user_id"], name: "user_id", using: :btree
    t.index ["hostname"], name: "hostname", using: :btree
  end

  create_table "job_execution_outputs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id",                    null: false
    t.integer  "execution_id",               null: false
    t.integer  "seq",                        null: false
    t.text     "output",       limit: 65535, null: false
    t.datetime "timestamp",                  null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["user_id"], name: "user_id", using: :btree
    t.index ["execution_id"], name: "execution_id", using: :btree
    t.index ["seq"], name: "seq", using: :btree
  end

  create_table "jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id",                                       null: false
    t.string   "name"
    t.text     "command",          limit: 65535,                null: false
    t.string   "command_hash",          limit: 64,                null: false
    t.boolean  "enabled",                        default: true
    t.integer  "executions_count",               default: 0
    t.integer  "schedules_count",                default: 0
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.index ["user_id"], name: "user_id", using: :btree
    t.index ["command_hash"], name: "command_hash", unique: true, using: :btree
    t.index ["created_at"], name: "created_at", using: :btree
  end

  create_table "schedules", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id",                      null: false
    t.integer  "job_id",                       null: false
    t.string   "minute",           limit: 169
    t.string   "hour",             limit: 61
    t.string   "day_of_the_month", limit: 83
    t.string   "month",            limit: 26
    t.string   "day_of_the_week",  limit: 13
    t.string   "special",          limit: 9
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["user_id"], name: "user_id", using: :btree
    t.index ["job_id"], name: "job_id", using: :btree
    t.index ["day_of_the_month"], name: "day_of_the_month", using: :btree
    t.index ["day_of_the_week"], name: "day_of_the_week", using: :btree
    t.index ["hour"], name: "hour", using: :btree
    t.index ["minute"], name: "minute", using: :btree
    t.index ["month"], name: "month", using: :btree
    t.index ["special"], name: "special", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",                   null: false
    t.string   "email",                  null: false
    t.string   "password",   limit: 202, null: false
    t.string   "api_key",    limit: 64,  null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["email"], name: "email", using: :btree
    t.index ["api_key"], name: "unique_api_key_per_user", unique: true, using: :btree
  end
end
