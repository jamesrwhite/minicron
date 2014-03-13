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

  create_table "hosts", force: true do |t|
    t.string   "hostname",   default: "", null: false
    t.string   "name"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.text     "public_key"
    t.index ["hostname"], :name => "hostname"
  end

  create_table "jobs", force: true do |t|
    t.string   "job_hash",   limit: 32, default: "", null: false
    t.string   "name"
    t.text     "command",                            null: false
    t.integer  "host_id",                            null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.index ["host_id"], :name => "host_id"
    t.index ["job_hash"], :name => "job_hash", :unique => true
    t.foreign_key ["host_id"], "hosts", ["id"], :on_update => :cascade, :on_delete => :cascade, :name => "jobs_ibfk_1"
  end

  create_table "executions", force: true do |t|
    t.integer  "job_id",      null: false
    t.integer  "host_id",     null: false
    t.datetime "created_at",  null: false
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer  "exit_status"
    t.index ["host_id"], :name => "host_id"
    t.index ["job_id"], :name => "job_id"
    t.foreign_key ["host_id"], "hosts", ["id"], :on_update => :cascade, :on_delete => :cascade, :name => "executions_ibfk_1"
    t.foreign_key ["job_id"], "jobs", ["id"], :on_update => :cascade, :on_delete => :cascade, :name => "executions_ibfk_2"
  end

  create_table "job_execution_outputs", force: true do |t|
    t.integer  "execution_id", null: false
    t.text     "output",       null: false
    t.datetime "timestamp",    null: false
    t.index ["execution_id"], :name => "execution_id"
    t.foreign_key ["execution_id"], "executions", ["id"], :on_update => :cascade, :on_delete => :cascade, :name => "job_execution_outputs_ibfk_1"
  end

end
