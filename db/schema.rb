# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20170213155613) do

  create_table "activities", force: :cascade do |t|
    t.integer  "user_id",        limit: 4
    t.string   "action",         limit: 255
    t.integer  "trackable_id",   limit: 4
    t.string   "trackable_type", limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "activities", ["trackable_type", "trackable_id"], name: "index_activities_on_trackable_type_and_trackable_id", using: :btree
  add_index "activities", ["user_id"], name: "index_activities_on_user_id", using: :btree

  create_table "addresses", force: :cascade do |t|
    t.string   "address1",      limit: 255
    t.string   "address2",      limit: 255
    t.string   "city",          limit: 255
    t.string   "state",         limit: 255
    t.string   "zip",           limit: 255
    t.text     "other_details", limit: 65535
    t.integer  "vendor_id",     limit: 4
    t.string   "country",       limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "contact_id",    limit: 4
  end

  add_index "addresses", ["contact_id"], name: "index_addresses_on_contact_id", using: :btree
  add_index "addresses", ["vendor_id"], name: "index_addresses_on_vendor_id", using: :btree

  create_table "agreement_documents", force: :cascade do |t|
    t.integer  "agreement_id", limit: 4
    t.integer  "file_size",    limit: 4
    t.string   "file_name",    limit: 255
    t.string   "created_by",   limit: 255
    t.string   "file_url",     limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "filename",     limit: 255
  end

  add_index "agreement_documents", ["agreement_id"], name: "index_agreement_documents_on_agreement_id", using: :btree

  create_table "agreement_statuses", force: :cascade do |t|
    t.string "status", limit: 255
  end

  create_table "agreements", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.integer  "agreement_status_id", limit: 4
    t.integer  "vendor_id",           limit: 4
    t.text     "description",         limit: 65535
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "expiration_date",     limit: 255
    t.string   "created_by",          limit: 255
    t.boolean  "active",              limit: 1,     default: false
    t.text     "revoke_reason",       limit: 65535
    t.integer  "user_id",             limit: 4
    t.string   "updated_by",          limit: 255
    t.integer  "rank",                limit: 4
  end

  add_index "agreements", ["agreement_status_id"], name: "index_agreements_on_agreement_status_id", using: :btree
  add_index "agreements", ["updated_at"], name: "index_agreements_on_updated_at", using: :btree
  add_index "agreements", ["user_id"], name: "index_agreements_on_user_id", using: :btree
  add_index "agreements", ["vendor_id"], name: "index_agreements_on_vendor_id", using: :btree

  create_table "bottles", force: :cascade do |t|
    t.string   "barcode_parent",      limit: 255
    t.string   "barcode",             limit: 255
    t.string   "status",              limit: 255
    t.string   "compound_name",       limit: 255
    t.string   "cas",                 limit: 255
    t.string   "cid",                 limit: 255
    t.string   "vendor",              limit: 255
    t.string   "vendor_part_number",  limit: 255
    t.integer  "qty_available_mg",    limit: 4
    t.integer  "qty_available_ul",    limit: 4
    t.integer  "concentration_mm",    limit: 4
    t.integer  "qty_available_umols", limit: 4
    t.string   "structure_real_amw",  limit: 255
    t.string   "sam",                 limit: 255
    t.string   "cpd",                 limit: 255
    t.string   "po_number",           limit: 255
    t.string   "lot_number",          limit: 255
    t.string   "form",                limit: 255
    t.string   "date_record_added",   limit: 255
    t.string   "solubility",          limit: 255
    t.string   "solubility_details",  limit: 255
    t.integer  "coa_summary_id",      limit: 4
    t.boolean  "can_plate",           limit: 1,     default: true
    t.string   "stripped_barcode",    limit: 255
    t.integer  "qty_available_mg_ul", limit: 4
    t.string   "units",               limit: 255
    t.text     "error",               limit: 65535
    t.text     "comments",            limit: 65535
    t.string   "qc_ts_molwt",         limit: 255
    t.string   "qc_struct_real_amw",  limit: 255
    t.text     "details",             limit: 65535
    t.string   "max_plated_conc_mm",  limit: 255
    t.string   "date_modified",       limit: 255
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.boolean  "external_bottle",     limit: 1,     default: false
    t.text     "comment",             limit: 65535
    t.integer  "freeze_thaw_count",   limit: 4
    t.string   "smiles",              limit: 255
    t.string   "updated_by",          limit: 255
    t.string   "solubility_solvent",  limit: 255
  end

  add_index "bottles", ["barcode"], name: "index_bottles_on_barcode", using: :btree
  add_index "bottles", ["barcode_parent"], name: "index_bottles_on_barcode_parent", using: :btree
  add_index "bottles", ["coa_summary_id"], name: "index_bottles_on_coa_summary_id", using: :btree
  add_index "bottles", ["lot_number"], name: "index_bottles_on_lot_number", using: :btree
  add_index "bottles", ["stripped_barcode"], name: "index_bottles_on_stripped_barcode", unique: true, using: :btree

  create_table "btl_comits", force: :cascade do |t|
    t.integer  "comit_id",   limit: 4
    t.integer  "bottle_id",  limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "chemical_lists", force: :cascade do |t|
    t.string   "list_abbreviation",      limit: 255
    t.string   "list_name",              limit: 255
    t.string   "list_description",       limit: 255
    t.string   "ncct_contact",           limit: 255
    t.string   "source_contact",         limit: 255
    t.string   "source_contact_email",   limit: 255
    t.string   "list_type",              limit: 255
    t.string   "list_update_mechanism",  limit: 255
    t.string   "list_accessibility",     limit: 255
    t.string   "curation_complete",      limit: 255
    t.string   "source_data_updated_at", limit: 255
    t.string   "created_by",             limit: 255
    t.string   "updated_by",             limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "coa_summaries", force: :cascade do |t|
    t.string   "bottle_barcode",        limit: 255
    t.integer  "coa_table_entry",       limit: 4
    t.string   "coa",                   limit: 255
    t.string   "msds",                  limit: 255
    t.string   "inventory_source",      limit: 255
    t.string   "coa_product_no",        limit: 255
    t.string   "coa_lot_number",        limit: 255
    t.string   "coa_chemical_name",     limit: 255
    t.string   "coa_casrn",             limit: 255
    t.integer  "coa_molecular_weight",  limit: 4
    t.string   "coa_density",           limit: 255
    t.string   "coa_purity_percentage", limit: 255
    t.string   "coa_methods",           limit: 255
    t.string   "coa_test_date",         limit: 255
    t.string   "coa_expiration_date",   limit: 255
    t.text     "msds_cautions",         limit: 65535
    t.text     "coa_review_notes",      limit: 65535
    t.string   "reviewer_initials",     limit: 255
    t.string   "commercial_source",     limit: 255
    t.integer  "user_id",               limit: 4
    t.integer  "gsid",                  limit: 4
    t.string   "date_record_added",     limit: 255
    t.string   "date_record_modified",  limit: 255
    t.integer  "source_substance_id",   limit: 4
    t.integer  "chemical_list_id",      limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "coa_summaries", ["bottle_barcode"], name: "index_coa_summaries_on_bottle_barcode", using: :btree
  add_index "coa_summaries", ["coa_casrn"], name: "index_coa_summaries_on_coa_casrn", using: :btree
  add_index "coa_summaries", ["coa_chemical_name"], name: "index_coa_summaries_on_coa_chemical_name", using: :btree
  add_index "coa_summaries", ["gsid"], name: "index_coa_summaries_on_gsid", using: :btree
  add_index "coa_summaries", ["source_substance_id"], name: "index_coa_summaries_on_source_substance_id", using: :btree
  add_index "coa_summaries", ["user_id"], name: "index_coa_summaries_on_user_id", using: :btree

  create_table "coa_summary_files", force: :cascade do |t|
    t.integer  "user_id",           limit: 4
    t.string   "filename",          limit: 255
    t.string   "file_url",          limit: 255
    t.integer  "file_kilobytes",    limit: 4
    t.integer  "coa_summary_count", limit: 4
    t.boolean  "is_valid",          limit: 1
    t.text     "description",       limit: 65535
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "record_error",      limit: 4
  end

  add_index "coa_summary_files", ["user_id"], name: "index_coa_summary_files_on_user_id", using: :btree

  create_table "coa_uploads", force: :cascade do |t|
    t.text     "coa_pdfs",   limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "coas", force: :cascade do |t|
    t.string   "filename",       limit: 255
    t.string   "file_url",       limit: 255
    t.integer  "file_kilobytes", limit: 4
    t.integer  "user_id",        limit: 4
    t.integer  "coa_summary_id", limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "barcode",        limit: 255
  end

  add_index "coas", ["coa_summary_id"], name: "index_coas_on_coa_summary_id", using: :btree
  add_index "coas", ["user_id"], name: "index_coas_on_user_id", using: :btree

  create_table "comits", force: :cascade do |t|
    t.string   "filename",          limit: 255
    t.string   "file_url",          limit: 255
    t.integer  "file_kilobytes",    limit: 4
    t.integer  "file_record_count", limit: 4
    t.integer  "added_by_user_id",  limit: 4
    t.integer  "user_id",           limit: 4
    t.string   "file_app_name",     limit: 255
    t.integer  "inserts",           limit: 4
    t.integer  "deletes",           limit: 4
    t.integer  "updates",           limit: 4
    t.boolean  "processing",        limit: 1,   default: true
    t.boolean  "is_valid",          limit: 1
    t.integer  "bottle_count",      limit: 4
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "comits", ["user_id"], name: "index_comits_on_user_id", using: :btree

  create_table "compounds", force: :cascade do |t|
    t.string   "dsstox_compound_id", limit: 255
    t.text     "smiles",             limit: 65535
    t.text     "inchi",              limit: 65535
    t.string   "mol_formula",        limit: 255
    t.integer  "mol_weight",         limit: 4
    t.string   "created_by",         limit: 255
    t.string   "updated_by",         limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "contact_types", force: :cascade do |t|
    t.string   "kind",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "contacts", force: :cascade do |t|
    t.string   "first_name",      limit: 255
    t.string   "last_name",       limit: 255
    t.integer  "vendor_id",       limit: 4
    t.string   "email",           limit: 255
    t.string   "title",           limit: 255
    t.string   "phone1",          limit: 255
    t.string   "phone2",          limit: 255
    t.string   "fax",             limit: 255
    t.string   "cell",            limit: 255
    t.text     "other_details",   limit: 65535
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "department",      limit: 255
    t.integer  "contact_type_id", limit: 4
  end

  add_index "contacts", ["contact_type_id"], name: "index_contacts_on_contact_type_id", using: :btree
  add_index "contacts", ["vendor_id"], name: "index_contacts_on_vendor_id", using: :btree

  create_table "controls", force: :cascade do |t|
    t.integer  "order_id",                   limit: 4
    t.integer  "source_substance_id",        limit: 4
    t.boolean  "controls",                   limit: 1,   default: false
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.string   "identifier",                 limit: 255
    t.boolean  "standard_replicate",         limit: 1,   default: false
    t.boolean  "originally_found_replicate", limit: 1,   default: false
  end

  add_index "controls", ["order_id"], name: "index_controls_on_order_id", using: :btree
  add_index "controls", ["source_substance_id"], name: "index_controls_on_source_substance_id", using: :btree

  create_table "cor_relationships", force: :cascade do |t|
    t.integer  "cor_id",     limit: 4
    t.integer  "user_id",    limit: 4
    t.string   "user_type",  limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "cor_relationships", ["updated_at"], name: "index_cor_relationships_on_updated_at", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",         limit: 4,     default: 0, null: false
    t.integer  "attempts",         limit: 4,     default: 0, null: false
    t.text     "handler",          limit: 65535,             null: false
    t.text     "last_error",       limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",        limit: 255
    t.string   "queue",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "progress_stage",   limit: 255
    t.integer  "progress_current", limit: 4,     default: 0
    t.integer  "progress_max",     limit: 4,     default: 0
    t.integer  "comit_id",         limit: 4
    t.integer  "job_id",           limit: 4
    t.string   "job_type",         limit: 255
  end

  add_index "delayed_jobs", ["comit_id"], name: "index_delayed_jobs_on_comit_id", using: :btree
  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "file_errors", force: :cascade do |t|
    t.text     "error_a",        limit: 65535
    t.text     "error_b",        limit: 65535
    t.integer  "error_count",    limit: 4
    t.integer  "errorable_id",   limit: 4
    t.string   "errorable_type", limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.text     "error_c",        limit: 65535
  end

  add_index "file_errors", ["errorable_type", "errorable_id"], name: "index_file_errors_on_errorable_type_and_errorable_id", using: :btree
  add_index "file_errors", ["updated_at"], name: "index_file_errors_on_updated_at", using: :btree

  create_table "generic_substance_compounds", force: :cascade do |t|
    t.integer  "fk_generic_substance_id", limit: 4
    t.integer  "fk_compound_id",          limit: 4
    t.string   "relationship",            limit: 255
    t.string   "source",                  limit: 255
    t.string   "created_by",              limit: 255
    t.string   "updated_by",              limit: 255
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "generic_substance_compounds", ["fk_compound_id"], name: "index_generic_substance_compounds_on_fk_compound_id", using: :btree
  add_index "generic_substance_compounds", ["fk_generic_substance_id"], name: "index_generic_substance_compounds_on_fk_generic_substance_id", using: :btree

  create_table "generic_substances", force: :cascade do |t|
    t.string   "dsstox_substance_id", limit: 255
    t.string   "casrn",               limit: 255
    t.string   "preferred_name",      limit: 255
    t.string   "substance_type",      limit: 255
    t.string   "qc_level",            limit: 255
    t.string   "qc_notes",            limit: 255
    t.string   "qc_notes_private",    limit: 255
    t.string   "source",              limit: 255
    t.string   "created_by",          limit: 255
    t.string   "updated_by",          limit: 255
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "mentor_postdocs", force: :cascade do |t|
    t.integer  "post_doc_id", limit: 4
    t.integer  "cor_id",      limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "msds", force: :cascade do |t|
    t.string   "filename",       limit: 255
    t.string   "file_url",       limit: 255
    t.integer  "file_kilobytes", limit: 4
    t.integer  "user_id",        limit: 4
    t.integer  "coa_summary_id", limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "barcode",        limit: 255
  end

  add_index "msds", ["coa_summary_id"], name: "index_msds_on_coa_summary_id", using: :btree
  add_index "msds", ["user_id"], name: "index_msds_on_user_id", using: :btree

  create_table "msds_uploads", force: :cascade do |t|
    t.text     "msds_pdfs",  limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "order_chemical_lists", force: :cascade do |t|
    t.integer  "order_id",         limit: 4
    t.integer  "chemical_list_id", limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "order_chemical_lists", ["chemical_list_id"], name: "index_order_chemical_lists_on_chemical_list_id", using: :btree
  add_index "order_chemical_lists", ["order_id"], name: "index_order_chemical_lists_on_order_id", using: :btree

  create_table "order_comments", force: :cascade do |t|
    t.text     "body",             limit: 65535
    t.integer  "commentable_id",   limit: 4
    t.string   "commentable_type", limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "created_by",       limit: 255
  end

  create_table "order_concentrations", force: :cascade do |t|
    t.integer "concentration", limit: 4
    t.string  "unit",          limit: 255
  end

  create_table "order_plate_details", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.integer  "order_id",      limit: 4
    t.text     "empty",         limit: 65535
    t.text     "solvent",       limit: 65535
    t.text     "control",       limit: 65535
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "plate_type_id", limit: 4
  end

  add_index "order_plate_details", ["order_id"], name: "index_order_plate_details_on_order_id", using: :btree
  add_index "order_plate_details", ["plate_type_id"], name: "index_order_plate_details_on_plate_type_id", using: :btree
  add_index "order_plate_details", ["user_id"], name: "index_order_plate_details_on_user_id", using: :btree

  create_table "order_statuses", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "step_number", limit: 4
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id",                   limit: 4
    t.integer  "vendor_id",                 limit: 4
    t.integer  "task_order_id",             limit: 4
    t.string   "concentration",             limit: 255
    t.integer  "amount",                    limit: 4
    t.string   "amount_unit",               limit: 255
    t.integer  "order_status_id",           limit: 4
    t.integer  "chemical_list_id",          limit: 4
    t.integer  "address_id",                limit: 4
    t.integer  "order_concentration_id",    limit: 4
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.boolean  "rejected",                  limit: 1,   default: false
    t.boolean  "resubmitted",               limit: 1,   default: false
    t.boolean  "using_standard_replicates", limit: 1,   default: false
  end

  add_index "orders", ["address_id"], name: "index_orders_on_address_id", using: :btree
  add_index "orders", ["order_concentration_id"], name: "index_orders_on_order_concentration_id", using: :btree
  add_index "orders", ["order_status_id"], name: "index_orders_on_order_status_id", using: :btree
  add_index "orders", ["task_order_id"], name: "index_orders_on_task_order_id", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree
  add_index "orders", ["vendor_id"], name: "index_orders_on_vendor_id", using: :btree

  create_table "plate_details", force: :cascade do |t|
    t.text     "ism",                   limit: 65535
    t.string   "sample_id",             limit: 255
    t.string   "structure_id",          limit: 255
    t.string   "structure_real_amw",    limit: 255
    t.string   "sample_supplier",       limit: 255
    t.string   "supplier_structure_id", limit: 255
    t.string   "aliquot_plate_barcode", limit: 255
    t.string   "aliquot_well_id",       limit: 255
    t.string   "aliquot_solvent",       limit: 255
    t.integer  "aliquot_conc",          limit: 4
    t.string   "aliquot_conc_unit",     limit: 255
    t.integer  "aliquot_volume",        limit: 4
    t.string   "aliquot_volume_unit",   limit: 255
    t.string   "sample_appearance",     limit: 255
    t.string   "structure_name",        limit: 255
    t.string   "cas_regno",             limit: 255
    t.string   "supplier_sample_id",    limit: 255
    t.string   "aliquot_date",          limit: 255
    t.string   "solubilized_barcode",   limit: 255
    t.string   "lts_barcode",           limit: 255
    t.string   "source_barcode",        limit: 255
    t.integer  "bottle_id",             limit: 4
    t.integer  "shipment_file_id",      limit: 4
    t.string   "blinded_sample_id",     limit: 255
    t.integer  "plate_id",              limit: 4
    t.string   "legacy_id",             limit: 255
    t.string   "legacy_sample",         limit: 255
    t.string   "legacy_sample_id",      limit: 255
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.boolean  "mapped_other",          limit: 1,     default: false
  end

  add_index "plate_details", ["aliquot_plate_barcode"], name: "index_plate_details_on_aliquot_plate_barcode", using: :btree
  add_index "plate_details", ["blinded_sample_id"], name: "index_plate_details_on_blinded_sample_id", using: :btree
  add_index "plate_details", ["bottle_id"], name: "index_plate_details_on_bottle_id", using: :btree
  add_index "plate_details", ["plate_id"], name: "index_plate_details_on_plate_id", using: :btree
  add_index "plate_details", ["shipment_file_id"], name: "index_plate_details_on_shipment_file_id", using: :btree
  add_index "plate_details", ["source_barcode"], name: "index_plate_details_on_source_barcode", using: :btree

  create_table "plate_types", force: :cascade do |t|
    t.string  "label",         limit: 255
    t.integer "numeric_value", limit: 4
  end

  create_table "plates", force: :cascade do |t|
    t.integer  "shipment_file_id",      limit: 4
    t.integer  "plate_count",           limit: 4
    t.string   "ship_id",               limit: 255
    t.string   "aliquot_plate_barcode", limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "plates", ["aliquot_plate_barcode"], name: "index_plates_on_aliquot_plate_barcode", using: :btree
  add_index "plates", ["ship_id"], name: "index_plates_on_ship_id", using: :btree
  add_index "plates", ["shipment_file_id"], name: "index_plates_on_shipment_file_id", using: :btree

  create_table "queries", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "label",          limit: 255
    t.text     "description",    limit: 65535
    t.string   "created_by",     limit: 255
    t.string   "sql",            limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "count",          limit: 4
    t.string   "conditions",     limit: 255
    t.string   "complete_query", limit: 255
    t.string   "updated_by",     limit: 255
  end

  create_table "roles", force: :cascade do |t|
    t.string   "role_type",  limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "samples", force: :cascade do |t|
    t.string   "source_barcode", limit: 255
    t.integer  "gsid",           limit: 4
    t.text     "notes",          limit: 65535
    t.string   "data_type",      limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "samples", ["gsid"], name: "index_samples_on_gsid", using: :btree
  add_index "samples", ["source_barcode"], name: "index_samples_on_source_barcode", using: :btree

  create_table "shipment_files", force: :cascade do |t|
    t.integer  "user_id",                limit: 4
    t.string   "filename",               limit: 255
    t.string   "file_url",               limit: 255
    t.integer  "file_kilobytes",         limit: 4
    t.text     "comment",                limit: 65535
    t.integer  "vendor_id",              limit: 4
    t.string   "order_number",           limit: 255
    t.string   "evotech_order_num",      limit: 255
    t.string   "evotech_shipment_num",   limit: 255
    t.string   "original_filename",      limit: 255
    t.string   "chemical_set",           limit: 255
    t.string   "e_ship_num_change",      limit: 255
    t.integer  "target_conc_mm",         limit: 4
    t.integer  "shipped_date",           limit: 4
    t.integer  "asid",                   limit: 4
    t.string   "asnm",                   limit: 255
    t.string   "use_disposition",        limit: 255
    t.integer  "plate_set_count",        limit: 4
    t.integer  "plate_set",              limit: 4
    t.string   "solvent",                limit: 255
    t.integer  "aliquot_date",           limit: 4
    t.integer  "legacy_date_added",      limit: 4
    t.string   "ship_id",                limit: 255
    t.boolean  "vial",                   limit: 1,     default: false
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.integer  "task_order_id",          limit: 4
    t.integer  "address_id",             limit: 4
    t.integer  "order_concentration_id", limit: 4
    t.boolean  "external",               limit: 1,     default: false
    t.string   "plate_detail",           limit: 255
    t.integer  "amount",                 limit: 4
    t.string   "status",                 limit: 255,   default: "finalized"
    t.string   "amount_unit",            limit: 255
    t.integer  "order_id",               limit: 4
    t.boolean  "mixture",                limit: 1,     default: false
  end

  add_index "shipment_files", ["address_id"], name: "index_shipment_files_on_address_id", using: :btree
  add_index "shipment_files", ["order_concentration_id"], name: "index_shipment_files_on_order_concentration_id", using: :btree
  add_index "shipment_files", ["order_id"], name: "index_shipment_files_on_order_id", using: :btree
  add_index "shipment_files", ["ship_id"], name: "index_shipment_files_on_ship_id", using: :btree
  add_index "shipment_files", ["task_order_id"], name: "index_shipment_files_on_task_order_id", using: :btree
  add_index "shipment_files", ["user_id"], name: "index_shipment_files_on_user_id", using: :btree
  add_index "shipment_files", ["vendor_id"], name: "index_shipment_files_on_vendor_id", using: :btree

  create_table "shipments_activities", force: :cascade do |t|
    t.integer  "user_id",        limit: 4
    t.string   "action",         limit: 255
    t.string   "location_a",     limit: 255
    t.string   "location_b",     limit: 255
    t.integer  "trackable_id",   limit: 4
    t.string   "trackable_type", limit: 255
    t.string   "order_number",   limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "shipments_activities", ["trackable_type", "trackable_id"], name: "index_shipments_activities_on_trackable_type_and_trackable_id", using: :btree
  add_index "shipments_activities", ["user_id"], name: "index_shipments_activities_on_user_id", using: :btree

  create_table "shipments_bottles", force: :cascade do |t|
    t.integer  "shipment_file_id",   limit: 4
    t.string   "plate_barcode",      limit: 255
    t.integer  "bottle_id",          limit: 4
    t.integer  "concentration",      limit: 4
    t.string   "concentration_unit", limit: 255
    t.integer  "amount",             limit: 4
    t.string   "amount_unit",        limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "barcode",            limit: 255
    t.string   "well_id",            limit: 255
  end

  add_index "shipments_bottles", ["bottle_id"], name: "index_shipments_bottles_on_bottle_id", using: :btree
  add_index "shipments_bottles", ["shipment_file_id"], name: "index_shipments_bottles_on_shipment_file_id", using: :btree

  create_table "source_generic_substances", force: :cascade do |t|
    t.integer  "fk_source_substance_id",  limit: 4
    t.integer  "fk_generic_substance_id", limit: 4
    t.string   "created_by",              limit: 255
    t.string   "updated_by",              limit: 255
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "connection_reason",       limit: 255
    t.integer  "curator_validated",       limit: 4
    t.string   "qc_notes",                limit: 255
  end

  add_index "source_generic_substances", ["fk_generic_substance_id"], name: "index_source_generic_substances_on_fk_generic_substance_id", using: :btree
  add_index "source_generic_substances", ["fk_source_substance_id"], name: "index_source_generic_substances_on_fk_source_substance_id", using: :btree

  create_table "source_substance_identifiers", force: :cascade do |t|
    t.integer  "fk_source_substance_id",                limit: 4
    t.string   "identifier",                            limit: 255
    t.string   "identifier_type",                       limit: 255
    t.integer  "fk_source_substance_identifier_parent", limit: 4
    t.string   "created_by",                            limit: 255
    t.string   "updated_by",                            limit: 255
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  add_index "source_substance_identifiers", ["fk_source_substance_id"], name: "index_source_substance_identifiers_on_fk_source_substance_id", using: :btree
  add_index "source_substance_identifiers", ["identifier"], name: "index_source_substance_identifiers_on_identifier", using: :btree
  add_index "source_substance_identifiers", ["identifier_type"], name: "index_source_substance_identifiers_on_identifier_type", using: :btree

  create_table "source_substances", force: :cascade do |t|
    t.integer  "fk_chemical_list_id", limit: 4
    t.string   "dsstox_record_id",    limit: 255
    t.string   "casrn",               limit: 255
    t.string   "name",                limit: 1024
    t.string   "structure",           limit: 1024
    t.string   "external_id",         limit: 255
    t.string   "name_inchikey",       limit: 255
    t.string   "structure_inchikey",  limit: 255
    t.string   "warnings",            limit: 255
    t.string   "created_by",          limit: 255,  null: false
    t.string   "updated_by",          limit: 255,  null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "source_substances", ["casrn"], name: "index_source_substances_on_casrn", using: :btree
  add_index "source_substances", ["name"], name: "index_source_substances_on_name", length: {"name"=>255}, using: :btree
  add_index "source_substances", ["name_inchikey"], name: "index_source_substances_on_name_inchikey", using: :btree
  add_index "source_substances", ["structure_inchikey"], name: "index_source_substances_on_structure_inchikey", using: :btree
  add_index "source_substances", ["updated_at"], name: "index_source_substances_on_updated_at", using: :btree

  create_table "synonym_mvs", force: :cascade do |t|
    t.integer  "fk_generic_substance_id", limit: 4
    t.string   "identifier",              limit: 255
    t.string   "synonym_type",            limit: 255
    t.integer  "rank",                    limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "synonym_mvs", ["fk_generic_substance_id"], name: "index_synonym_mvs_on_fk_generic_substance_id", using: :btree
  add_index "synonym_mvs", ["identifier"], name: "index_synonym_mvs_on_identifier", using: :btree
  add_index "synonym_mvs", ["rank"], name: "index_synonym_mvs_on_rank", using: :btree
  add_index "synonym_mvs", ["synonym_type"], name: "index_synonym_mvs_on_synonym_type", using: :btree

  create_table "task_orders", force: :cascade do |t|
    t.integer  "vendor_id",    limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "agreement_id", limit: 4
    t.string   "name",         limit: 255
    t.text     "description",  limit: 65535
    t.string   "created_by",   limit: 255
    t.integer  "rank",         limit: 4
  end

  add_index "task_orders", ["agreement_id"], name: "index_task_orders_on_agreement_id", using: :btree
  add_index "task_orders", ["vendor_id"], name: "index_task_orders_on_vendor_id", using: :btree

  create_table "tox_21_chemicals", force: :cascade do |t|
    t.string  "t_tox21_id",           limit: 255
    t.string  "t_original_sample_id", limit: 255
    t.string  "t_partner",            limit: 255
    t.string  "t_tox21_ntp_sid",      limit: 255
    t.string  "t_tox21_ncgc_id",      limit: 255
    t.string  "t_pubchem_regid",      limit: 255
    t.integer "t_pubchem_sid",        limit: 4
    t.integer "t_pubchem_cid",        limit: 4
    t.string  "t_pubchem_name",       limit: 255
    t.string  "t_pubchem_cas",        limit: 255
    t.string  "t_qc_grade_id",        limit: 255
  end

  add_index "tox_21_chemicals", ["t_original_sample_id"], name: "index_tox_21_chemicals_on_t_original_sample_id", using: :btree
  add_index "tox_21_chemicals", ["t_tox21_id"], name: "index_tox_21_chemicals_on_t_tox21_id", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "f_name",                 limit: 255
    t.string   "l_name",                 limit: 255
    t.string   "picture",                limit: 255
    t.integer  "role_id",                limit: 4
    t.string   "username",               limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["role_id"], name: "index_users_on_role_id", using: :btree

  create_table "users_task_orders", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.integer  "task_order_id", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "users_task_orders", ["user_id"], name: "index_users_task_orders_on_user_id", using: :btree

  create_table "vendors", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "label",            limit: 255
    t.string   "phone1",           limit: 255
    t.string   "phone2",           limit: 255
    t.text     "other_details",    limit: 65535
    t.string   "short_name",       limit: 255
    t.string   "contact_name",     limit: 255
    t.string   "contact_title",    limit: 255
    t.string   "epa_contact_name", limit: 255
    t.string   "fax",              limit: 255
    t.string   "email",            limit: 255
    t.string   "date",             limit: 255
    t.string   "category",         limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "mta_partner",      limit: 1
  end

  create_table "vial_details", force: :cascade do |t|
    t.text     "ism",                   limit: 65535
    t.string   "sample_id",             limit: 255
    t.string   "structure_id",          limit: 255
    t.decimal  "structure_real_amw",                  precision: 10
    t.string   "sample_supplier",       limit: 255
    t.string   "supplier_structure_id", limit: 255
    t.string   "aliquot_plate_barcode", limit: 255
    t.string   "aliquot_well_id",       limit: 255
    t.string   "aliquot_vial_barcode",  limit: 255
    t.decimal  "aliquot_amount",                      precision: 16, scale: 2
    t.string   "aliquot_amount_unit",   limit: 255
    t.string   "sample_appearance",     limit: 255
    t.string   "structure_name",        limit: 255
    t.string   "cas_regno",             limit: 255
    t.string   "supplier_sample_id",    limit: 255
    t.string   "aliquot_date",          limit: 255
    t.string   "solubilized_barcode",   limit: 255
    t.string   "lts_barcode",           limit: 255
    t.string   "source_barcode",        limit: 255
    t.decimal  "purity",                              precision: 10
    t.string   "purity_method",         limit: 255
    t.integer  "bottle_id",             limit: 4
    t.integer  "shipment_file_id",      limit: 4
    t.string   "blinded_sample_id",     limit: 255
    t.string   "legacy_id",             limit: 255
    t.datetime "created_at",                                                                   null: false
    t.datetime "updated_at",                                                                   null: false
    t.boolean  "mapped_other",          limit: 1,                              default: false
  end

  add_index "vial_details", ["aliquot_plate_barcode"], name: "index_vial_details_on_aliquot_plate_barcode", using: :btree
  add_index "vial_details", ["blinded_sample_id"], name: "index_vial_details_on_blinded_sample_id", using: :btree
  add_index "vial_details", ["bottle_id"], name: "index_vial_details_on_bottle_id", using: :btree
  add_index "vial_details", ["legacy_id"], name: "index_vial_details_on_legacy_id", unique: true, using: :btree
  add_index "vial_details", ["shipment_file_id"], name: "index_vial_details_on_shipment_file_id", using: :btree
  add_index "vial_details", ["source_barcode"], name: "index_vial_details_on_source_barcode", using: :btree

  add_foreign_key "activities", "users"
  add_foreign_key "addresses", "contacts"
  add_foreign_key "addresses", "vendors"
  add_foreign_key "agreement_documents", "agreements"
  add_foreign_key "agreements", "agreement_statuses"
  add_foreign_key "agreements", "users"
  add_foreign_key "agreements", "vendors"
  add_foreign_key "bottles", "coa_summaries"
  add_foreign_key "coa_summaries", "users"
  add_foreign_key "coa_summary_files", "users"
  add_foreign_key "coas", "coa_summaries"
  add_foreign_key "coas", "users"
  add_foreign_key "comits", "users"
  add_foreign_key "contacts", "contact_types"
  add_foreign_key "contacts", "vendors"
  add_foreign_key "controls", "orders"
  add_foreign_key "delayed_jobs", "comits"
  add_foreign_key "msds", "coa_summaries"
  add_foreign_key "msds", "users"
  add_foreign_key "order_chemical_lists", "orders"
  add_foreign_key "order_plate_details", "orders"
  add_foreign_key "order_plate_details", "plate_types"
  add_foreign_key "order_plate_details", "users"
  add_foreign_key "orders", "addresses"
  add_foreign_key "orders", "order_concentrations"
  add_foreign_key "orders", "order_statuses"
  add_foreign_key "orders", "task_orders"
  add_foreign_key "orders", "users"
  add_foreign_key "orders", "vendors"
  add_foreign_key "plate_details", "bottles"
  add_foreign_key "plate_details", "shipment_files"
  add_foreign_key "plates", "shipment_files"
  add_foreign_key "shipment_files", "addresses"
  add_foreign_key "shipment_files", "order_concentrations"
  add_foreign_key "shipment_files", "orders"
  add_foreign_key "shipment_files", "task_orders"
  add_foreign_key "shipment_files", "users"
  add_foreign_key "shipment_files", "vendors"
  add_foreign_key "shipments_activities", "users"
  add_foreign_key "shipments_bottles", "bottles"
  add_foreign_key "shipments_bottles", "shipment_files"
  add_foreign_key "task_orders", "agreements"
  add_foreign_key "task_orders", "vendors"
  add_foreign_key "users", "roles"
  add_foreign_key "users_task_orders", "users"
  add_foreign_key "vial_details", "bottles"
  add_foreign_key "vial_details", "shipment_files"
end
