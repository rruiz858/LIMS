json.array!(@bottles) do |bottle|
  json.extract! bottle, :id, :barcode_parent, :barcode,:status,:cid, :vendor, :vendor_part_number, :compound_name, :cas, :qty_available_mg,:qty_available_ul,:concentration_mm,:qty_available_umols, :structure_real_amw,:sam,:cpd, :po_number,:lot_number,:form,:date_record_added,:solubility_dmso,:solubitity_details, :coa_summary_id, :can_plate
  json.url bottle_url(bottle, format: :json)
end
