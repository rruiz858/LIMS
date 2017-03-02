json.array!(@coa_summaries) do |coa_summary|
  json.extract! coa_summary, :id, :bottle_barcode, :coa_table_entry, :coa, :msds, :inventory_source, :coa_product_no, :coa_lot_number, :coa_chemical_name, :coa_casrn, :coa_molecular_weight, :coa_density, :coa_purity_percentage, :coa_methods, :coa_test_date, :coa_expiration_date, :msds_cautions, :coa_review_notes, :gsid, :reviewer_initials, :commercial_source
  json.url coa_summary_url(coa_summary, format: :json)
end
