require 'io/console'
task :legacy do

  puts "User name?"
  username = STDIN.gets.chomp
  puts "password?"
  password = STDIN.noecho(&:gets).chomp
  puts "Which ChemTrack schema do you want to use? sbox_chemtrack_rruizvev or dev_chemtrack or prod_chemtrack? "
  schema = STDIN.gets.chomp
  puts "Which version of dsstox? sbox_dsstox or whatever else Chris decides to make"
  dsstox_schema = STDIN.gets.chomp

  ActiveRecord::Base.establish_connection(
      :adapter => "mysql2",
      :host => "au.epa.gov",
      :username => "#{username}",
      :password => "#{password}",
  )

  puts "###################"
  puts "The Rake task has begun"
  puts "##################"
  ActiveRecord::Base.connection.execute("SET foreign_key_checks = 0")
  ActiveRecord::Base.connection.execute("set SQL_SAFE_UPDATES = 0;")


  puts "Beginning the loading of bottle to bottles"

  ActiveRecord::Base.connection.execute("
           TRUNCATE #{schema}.bottles")

  ActiveRecord::Base.connection.execute("INSERT INTO #{schema}.bottles (stripped_barcode, coa_summary_id, barcode_parent, barcode, status, compound_name, cas, vendor, vendor_part_number, qty_available_mg_ul, units, concentration_mm, qty_available_umols, structure_real_amw, sam, cpd, po_number, lot_number, form, solubility_dmso, solubitity_details, error, comments, qc_ts_molwt, qc_struct_real_amw, details, max_plated_conc_mm, created_at, updated_at)
           SELECT b_bottle_id, b_coa_id, b_barcode_parent, b_barcode, b_status, b_vendor_compound_name, b_vendor_cas, b_vendor, b_vendor_part_number, b_qty_available_mg_ul, b_units, b_concentration_mm, b_qty_available_umols, b_structure_real_amw, b_sam, b_cpd, b_po_number, b_lot_number, b_form, b_solubility_dmso, b_solubility_details, b_error, b_comments, b_qc_ts_molwt, b_qc_struct_real_amw, b_details, max_plated_conc_mm, b_date_record_added, b_date_modified
           FROM cheminventory.bottle
           WHERE b_date_record_added IS NOT NULL AND b_date_modified IS NOT NULL;")
  ActiveRecord::Base.connection.execute("INSERT INTO #{schema}.bottles (stripped_barcode, coa_summary_id, barcode_parent, barcode, status, compound_name, cas, vendor, vendor_part_number, qty_available_mg_ul, units, concentration_mm, qty_available_umols, structure_real_amw, sam, cpd, po_number, lot_number, form, solubility_dmso, solubitity_details, error, comments, qc_ts_molwt, qc_struct_real_amw, details, max_plated_conc_mm, created_at, updated_at)
           SELECT b_bottle_id, b_coa_id, b_barcode_parent, b_barcode, b_status, b_vendor_compound_name, b_vendor_cas, b_vendor, b_vendor_part_number, b_qty_available_mg_ul, b_units, b_concentration_mm, b_qty_available_umols, b_structure_real_amw, b_sam, b_cpd, b_po_number, b_lot_number, b_form, b_solubility_dmso, b_solubility_details, b_error, b_comments, b_qc_ts_molwt, b_qc_struct_real_amw, b_details, max_plated_conc_mm, b_date_record_added, 00000000
           FROM cheminventory.bottle
           WHERE b_date_record_added IS NOT NULL AND b_date_modified IS NULL;")


  puts "Finished"
  puts "Beginning the loading of coa to coasummaries"
  puts "Created a chemical list for COA Summaries"

  ActiveRecord::Base.connection.execute("INSERT INTO #{dsstox_schema}.chemical_lists (list_abbreviation, list_name, ncct_contact, source_contact, source_contact_email, list_type, list_update_mechanism, list_accessibility, curation_complete, source_data_updated_at, created_by, updated_by, created_at, updated_at)
  VALUES ('COA_Summaries', '#{schema}_COA_Summary_Chemical_List', 'Ann Richard', 'Ann Richard', 'richard.ann@epa.gov', 'INDEX', 'PROGRAM', 'PUBLIC', 0, now(), 'rruizvev', 'rruizvev', now(), now()); ")

  ActiveRecord::Base.connection.execute("
         TRUNCATE #{schema}.coa_summaries")
  ActiveRecord::Base.connection.execute(
      "INSERT INTO #{schema}.coa_summaries (id, bottle_barcode, coa_table_entry, coa, msds, inventory_source, commercial_source, coa_product_no, coa_lot_number, coa_chemical_name, coa_casrn, coa_molecular_weight, coa_density, coa_purity_percentage, coa_methods, coa_test_date, coa_expiration_date, msds_cautions, coa_review_notes, gsid, reviewer_initials, created_at, updated_at, chemical_list_id)
           SELECT co_id,
                  co_bottle_id,
                  co_table_entry,
                  co_coa,
                  co_msds,
                  co_inventory_source,
                  co_commercial_source,
                  co_product_no,
                  co_lot_number,
                  co_chemical_name,
                  co_casrn,
                  co_molecular_weight,
                  co_density,
                  co_purity_percentage,
                  co_methods,
                  co_test_date,
                  co_expiration_date,
                  co_msds_cautions,
                  co_reviewer_notes,
                  co_gsid,
                  co_reviewer_initials,
                  co_date_record_added,
                  co_date_record_modified,
                  (SELECT MAX(id) FROM #{dsstox_schema}.chemical_lists)
           FROM cheminventory.coa
           WHERE co_date_record_added IS NOT NULL and co_date_record_added !=0 and co_date_record_modified IS NOT NULL;")

  ActiveRecord::Base.connection.execute(
      "INSERT INTO #{schema}.coa_summaries (id, bottle_barcode, coa_table_entry, coa, msds, inventory_source, commercial_source, coa_product_no, coa_lot_number, coa_chemical_name, coa_casrn, coa_molecular_weight, coa_density, coa_purity_percentage, coa_methods, coa_test_date, coa_expiration_date, msds_cautions, coa_review_notes, gsid, reviewer_initials, created_at, updated_at, chemical_list_id)
           SELECT co_id,
                  co_bottle_id,
                  co_table_entry,
                  co_coa,
                  co_msds,
                  co_inventory_source,
                  co_commercial_source,
                  co_product_no,
                  co_lot_number,
                  co_chemical_name,
                  co_casrn,
                  co_molecular_weight,
                  co_density,
                  co_purity_percentage,
                  co_methods,
                  co_test_date,
                  co_expiration_date,
                  co_msds_cautions,
                  co_reviewer_notes,
                  co_gsid,
                  co_reviewer_initials,
                  20150126,
                  0000000,
                  (SELECT MAX(id) FROM #{dsstox_schema}.chemical_lists)
           FROM cheminventory.coa
           WHERE co_date_record_added IS NULL OR co_date_record_added = 0")


  puts "Beginning the loading of vendor to vedors and addresses"
  ActiveRecord::Base.connection.execute("
          TRUNCATE #{schema}.vendors")

  ActiveRecord::Base.connection.execute("INSERT INTO #{schema}.vendors (id, name, label, contact_name, contact_title, epa_contact_name, phone1, phone2, fax, email, category, other_details, created_at, updated_at )
          SELECT v_id, v_vendor_id, v_company_name, v_contact, v_title, v_epa_contact, v_phone_office, v_phone_cell, v_fax, v_email, v_type, v_notes, v_date, 00000000 FROM cheminventory.vendor;")

  ActiveRecord::Base.connection.execute("
         TRUNCATE #{schema}.addresses")

  ActiveRecord::Base.connection.execute("INSERT INTO #{schema}.addresses (vendor_id, address1, address2, city, state, country, zip, created_at, updated_at ) SELECT
          v_id, v_ship_address_line1, v_ship_address_line2, v_city, v_state, v_country, v_zipcode, v_date, 00000000 FROM cheminventory.vendor;")

  ActiveRecord::Base.connection.execute("INSERT INTO #{schema}.addresses (vendor_id, address1, address2, city, state, country, zip, created_at, updated_at )
        SELECT v_id, v_address_line1, v_address_line2, v_city, v_state, v_country, v_zipcode, v_date, 00000000
        FROM cheminventory.vendor WHERE v_address_line1 != 'same';")

  puts "Adding Missing Vendors"
  ActiveRecord::Base.connection.execute("INSERT INTO #{schema}.vendors (name, label, phone1, created_at, updated_at, contact_name, epa_contact_name, email, date, category)
        VALUES ('SPadilla', 'EPA', '919-541-3956', now(), now(), 'Stephanie Padilla', 'Keith Houck', 'Padilla.stephanie@epa.go', now(), 'EPA distribution'); ")

  ActiveRecord::Base.connection.execute(" INSERT INTO #{schema}.vendors (name, label, phone1, created_at, updated_at, contact_name, epa_contact_name, email, date, category)
        VALUES ('Chris Corton', 'EPA', '919-541-0092', now(), now(), 'Chris Corton', 'Keith Houck', 'corton.chris@epa.gov', now(), 'EPA distribution'); ")


  ActiveRecord::Base.connection.execute(" INSERT INTO #{schema}.vendors (name, label, phone1, created_at, updated_at, contact_name, epa_contact_name, email, date, category)
        VALUES ('Steve Simmons', 'EPA', '919-541-0647', now(), now(), 'Steve Simmons', 'Keith Houck', 'Simmons.steve@epa.gov', now(), 'EPA distribution'); ")


  ActiveRecord::Base.connection.execute(" INSERT INTO #{schema}.vendors (name, label, phone1, created_at, updated_at, contact_name, epa_contact_name, email, date, category)
        VALUES ('Tim Shafer', 'EPA', '919-541-0647', now(), now(), 'Tim Shafer', 'Keith Houck', 'Shafer.tim@epa.gov', now(), 'EPA distribution'); ")


  ActiveRecord::Base.connection.execute(" INSERT INTO #{schema}.vendors (name, label, phone1, created_at, updated_at, contact_name, epa_contact_name, email, date, category)
        VALUES ('Bill Mundy', 'EPA', '919-541-0647', now(), now(), 'William Mundy', 'Keith Houck', 'Mundy.williams@epa.gov', now(), 'EPA distribution'); ")

  ActiveRecord::Base.connection.execute(" INSERT INTO #{schema}.vendors (name, label, phone1, created_at, updated_at, contact_name, epa_contact_name, email, date, category)
        VALUES ('Sid Hunter', 'EPA', '919-541-3490', now(), now(), 'Sid Hunter', 'Keith Houck', 'Mundy.williams@epa.gov', now(), 'EPA distribution'); ")


  ActiveRecord::Base.connection.execute(" INSERT INTO #{schema}.vendors (name, label, phone1, created_at, updated_at, contact_name, epa_contact_name, email, date, category)
        VALUES ('Katie Paul', 'EPA', '919-475-6158', now(), now(), 'Katie Paul Friedman', 'Keith Houck', 'Katie Paul Friedman', now(), 'EPA distribution, Bayer CropScience'); ")

  ActiveRecord::Base.connection.execute(" INSERT INTO #{schema}.vendors (name, label, phone1, created_at, updated_at, contact_name, epa_contact_name, email, date, category)
        VALUES ('Tamara Tal', 'EPA', '919-475-6158', now(), now(), 'Tamara Tal', 'Keith Houck', 'idk@epa.gov', now(), 'EPA distribution'); ")

  puts "Loading cheminventory.ship into chemtrack.shipment_files"
  #****Shipment_Files*************************************** where v_id is not 12 or zero.
  ActiveRecord::Base.connection.execute("TRUNCATE #{schema}.shipment_files;")

  ActiveRecord::Base.connection.execute ("INSERT INTO #{schema}.shipment_files ( ship_id, evotech_order_num, order_number, vendor_id, chemical_set, evotech_shipment_num, e_ship_num_change, plate_set_count, plate_set, solvent, target_conc_mm, aliquot_date, shipped_date, use_disposition, comment, asid, asnm, created_at, updated_at, user_id, filename, file_url, original_filename)
        SELECT
        s_ship_id, s_external_id, s_order_number, s_v_id, s_chemical_set, s_ship_number_id, s_ship_number_change, s_plate_set_count, s_plate_set, s_solvent, s_target_conc_mm, s_aliquot_date, s_shipped_date, s_use_disposition, s_comment, asid, asnm, s_date_added, 00000000, 1, CONCAT('legacy_',s_ship_id), CONCAT('legacy_',s_ship_id), CONCAT('legacy_',s_ship_id)
        FROM cheminventory.ship
        WHERE (s_v_id != 12 AND s_v_id !=0 AND s_v_id IS NOT NULL)
        ;")

  # ***********Shipment Files ********************When s_v_id is 12, s_v_freezer is 1, & epa_recipient is NULL or ""#

  ActiveRecord::Base.connection.execute("INSERT INTO #{schema}.shipment_files ( ship_id, evotech_order_num, order_number, vendor_id, chemical_set, evotech_shipment_num, e_ship_num_change, plate_set_count, plate_set, solvent, target_conc_mm, aliquot_date, shipped_date, use_disposition,comment, asid, asnm, created_at, updated_at, user_id, filename, file_url, original_filename)
        SELECT
        s_ship_id, s_external_id, s_order_number, s_v_id, s_chemical_set, s_ship_number_id, s_ship_number_change, s_plate_set_count, s_plate_set, s_solvent, s_target_conc_mm, s_aliquot_date, s_shipped_date, s_use_disposition, s_comment, asid, asnm, s_date_added, 00000000, 1, CONCAT('legacy_',s_ship_id), CONCAT('legacy_',s_ship_id), CONCAT('legacy_',s_ship_id)
        FROM cheminventory.ship
        WHERE s_v_id = 12 AND s_freezer = 1 AND (s_epa_recipient IS NULL OR s_epa_recipient = '' OR s_epa_recipient = '0' );")


  #*************************Shipment_Files*****************************When s_v_id is 12, s_v_freezer is  0, & epa_recipient is NOT NULL
  ActiveRecord::Base.connection.execute("INSERT INTO #{schema}.shipment_files ( ship_id, evotech_order_num, order_number, vendor_id, chemical_set, evotech_shipment_num, e_ship_num_change, plate_set_count, plate_set, solvent, target_conc_mm, aliquot_date, shipped_date, use_disposition, comment, asid, asnm, created_at, updated_at, user_id, filename, file_url, original_filename)
        SELECT
        cheminventory.ship.s_ship_id, cheminventory.ship.s_external_id, cheminventory.ship.s_order_number, #{schema}.vendors.id, cheminventory.ship.s_chemical_set, cheminventory.ship.s_ship_number_id, cheminventory.ship.s_ship_number_change, cheminventory.ship.s_plate_set_count, cheminventory.ship.s_plate_set, cheminventory.ship.s_solvent, cheminventory.ship.s_target_conc_mm, cheminventory.ship.s_aliquot_date, cheminventory.ship.s_shipped_date, cheminventory.ship.s_use_disposition, cheminventory.ship.s_comment, cheminventory.ship.asid, cheminventory.ship.asnm, cheminventory.ship.s_date_added, 00000000, 1 , CONCAT('legacy_', cheminventory.ship.s_ship_id), CONCAT('legacy_', cheminventory.ship.s_ship_id), CONCAT('legacy_', cheminventory.ship.s_ship_id)
        FROM #{schema}.vendors
        INNER JOIN cheminventory.ship
        ON #{schema}.vendors.name = cheminventory.ship.s_epa_recipient
        WHERE cheminventory.ship.s_v_id = '12' AND cheminventory.ship.s_freezer = '0'AND (cheminventory.ship.s_epa_recipient IS NOT NULL OR cheminventory.ship.s_epa_recipient != '' OR cheminventory.ship.s_epa_recipient != '0');")

  #*************************Shipment_Files*****************************When s_v_id is 12, s_v_freezer is  1, & epa_recipient is NOT NULL
  ActiveRecord::Base.connection.execute("INSERT INTO #{schema}.shipment_files ( ship_id, evotech_order_num, order_number, vendor_id, chemical_set, evotech_shipment_num, e_ship_num_change, plate_set_count, plate_set, solvent, target_conc_mm, aliquot_date, shipped_date, use_disposition, comment, asid, asnm, created_at, updated_at, user_id, filename, file_url, original_filename)
        SELECT
        cheminventory.ship.s_ship_id, cheminventory.ship.s_external_id, cheminventory.ship.s_order_number, #{schema}.vendors.id, cheminventory.ship.s_chemical_set, cheminventory.ship.s_ship_number_id, cheminventory.ship.s_ship_number_change, cheminventory.ship.s_plate_set_count, cheminventory.ship.s_plate_set, cheminventory.ship.s_solvent, cheminventory.ship.s_target_conc_mm, cheminventory.ship.s_aliquot_date, cheminventory.ship.s_shipped_date, cheminventory.ship.s_use_disposition, cheminventory.ship.s_comment, cheminventory.ship.asid, cheminventory.ship.asnm, cheminventory.ship.s_date_added, 00000000, 1,  CONCAT('legacy_', cheminventory.ship.s_ship_id) , CONCAT('legacy_', cheminventory.ship.s_ship_id), CONCAT('legacy_', cheminventory.ship.s_ship_id)
        FROM #{schema}.vendors
        INNER JOIN cheminventory.ship
        ON #{schema}.vendors.name = cheminventory.ship.s_epa_recipient
        WHERE cheminventory.ship.s_freezer = '1' AND cheminventory.ship.s_v_id = '12' AND (cheminventory.ship.s_epa_recipient IS NOT NULL OR cheminventory.ship.s_epa_recipient != '' OR cheminventory.ship.s_epa_recipient != '0' ); ")

  puts "Importing cheminventory.plates into chemtrack.plates"

  ActiveRecord::Base.connection.execute("TRUNCATE #{schema}.plates;")
  ActiveRecord::Base.connection.execute("INSERT INTO #{schema}.plates (aliquot_plate_barcode, ship_id, plate_count, created_at, updated_at )
         SELECT
         p_plate_id, p_ship_id, p_plate_count, now(), now()
         FROM cheminventory.plate;")

  puts "Importing cheminventory.tox21 into chemtrack.tox21_chemicals"
 ActiveRecord::Base.connection.execute("TRUNCATE #{schema}.tox_21_chemicals;")
ActiveRecord::Base.connection.execute("INSERT INTO #{schema}.tox_21_chemicals (t_tox21_id, t_original_sample_id, t_partner, t_tox21_ntp_sid, t_tox21_ncgc_id, t_pubchem_regid, t_pubchem_sid, t_pubchem_cid, t_pubchem_name, t_pubchem_cas, t_qc_grade_id)
         SELECT
         t_tox21_id, t_original_sample_id, t_partner, t_tox21_ntp_sid, t_tox21_ncgc_id, t_pubchem_regid, t_pubchem_sid, t_pubchem_cid, t_pubchem_name, t_pubchem_cas, t_qc_grade_id
         FROM cheminventory.tox21")

  puts "Importing cheminventory.sample into chemtrack.samples"
  ActiveRecord::Base.connection.execute("TRUNCATE #{schema}.samples;")
  ActiveRecord::Base.connection.execute("INSERT INTO #{schema}.samples (source_barcode, gsid, notes, data_type, created_at, updated_at)
         SELECT
         sa_sample_id, sa_gsid, sa_notes, sa_data_type,
         (CASE WHEN sa_date IS NOT NULL THEN sa_date ELSE 20151103 END) as created_at,
         (CASE WHEN sa_date IS NOT NULL THEN sa_date ELSE 20151103 END) as updated_at
         FROM cheminventory.sample")


  puts "Importing cheminventory.plate_details into chemtrack.plate_details"
  ActiveRecord::Base.connection.execute("TRUNCATE #{schema}.plate_details;")
  ####records that are not from Tox21 and can be mapped to bottles, note there are nearly 5000 records in
  #in cheminventory that do not map and therefore were not inserted
  ##This inserts 114637 into plate_details
  ActiveRecord::Base.connection.execute("INSERT INTO #{schema}.plate_details (legacy_id, blinded_sample_id, aliquot_plate_barcode, aliquot_well_id, aliquot_conc, aliquot_conc_unit, source_barcode, aliquot_volume, aliquot_volume_unit,created_at, updated_at)
         SELECT
         pd_id, pd_sample, pd_plate_id, pd_well, pd_conc, pd_conc_unit, pd_sample_id, pd_volume, pd_volume_unit, now(), now()
         FROM cheminventory.plate_detail AS pd
         INNER JOIN cheminventory.bottle AS b
         ON b.b_bottle_id = pd.pd_sample_id
         WHERE pd.pd_conc_unit != 'NA';")

  ##Following query inserts 351 records into vial_details
  puts "Importing cheminventory.plate_details into chemtrack.vial_details "
  ActiveRecord::Base.connection.execute("TRUNCATE #{schema}.vial_details;")
  ActiveRecord::Base.connection.execute("INSERT INTO #{schema}.vial_details (legacy_id, blinded_sample_id, aliquot_plate_barcode, aliquot_well_id, aliquot_amount, aliquot_amount_unit, source_barcode,created_at, updated_at)
       SELECT  pd_id, CONCAT(pd_plate_id,'_' ,pd_well), pd_plate_id, pd_well, pd_volume, pd_volume_unit, pd_sample_id, now(), now()
       FROM cheminventory.plate_detail AS pd
       INNER JOIN cheminventory.bottle AS b
       ON b.b_bottle_id = pd.pd_sample_id
       WHERE pd.pd_conc_unit = 'NA';")

##Following query enters 12774 records
  ActiveRecord::Base.connection.execute("INSERT INTO #{schema}.plate_details (legacy_id, blinded_sample_id, aliquot_plate_barcode, aliquot_well_id, aliquot_conc, aliquot_conc_unit, source_barcode, aliquot_volume, aliquot_volume_unit,created_at, updated_at)
         SELECT
         pd_id, pd_sample, pd_plate_id, pd_well, pd_conc, pd_conc_unit, pd_sample_id, pd_volume, pd_volume_unit, now(), now()
         FROM cheminventory.plate_detail AS pd
         WHERE pd.pd_conc_unit != 'NA'
         AND pd.pd_sample LIKE 'tox21%'
         AND pd.pd_sample_id LIKE 'tox21%';")

  puts "Linking chemtrack.bottles with chemtrack.plate_details"

  ActiveRecord::Base.connection.execute("update #{schema}.plate_details AS pd
         INNER JOIN #{schema}.bottles AS b
         ON pd.source_barcode = b.stripped_barcode
         set pd.bottle_id = b.id;")

  puts "Linking chemtrack.bottles with Tox21 chemtrack.plate_details"
  #This section updates the Tox21 records provided by the epa that contains a t_'
  # original_sample_id that is found in the bottle table
  ActiveRecord::Base.connection.execute("update #{schema}.plate_details AS pd
        INNER JOIN #{schema}.tox_21_chemicals AS tx
        ON tx.t_tox21_id = pd.source_barcode
        INNER JOIN #{schema}.bottles AS b
        ON b.stripped_barcode = tx.t_original_sample_id
        set pd.bottle_id = b.id;")
  #This section creates new bottles and new coa summaries for each record in plate_details from Tox21 # that was not found in the bottle table
  #This section enters 9045 coa_summaries
  ActiveRecord::Base.connection.execute("INSERT INTO #{schema}.coa_summaries(bottle_barcode, gsid, created_at, updated_at, chemical_list_id)
         SELECT CONCAT(t_tox21_id, '_legacy'),
         s.gsid,
         now(),
         now(),
         (SELECT MAX(id) FROM #{dsstox_schema}.chemical_lists)
         FROM #{schema}.tox_21_chemicals AS tx
         INNER JOIN #{schema}.plate_details AS pd
         ON pd.source_barcode = tx.t_tox21_id
         INNER JOIN #{schema}.samples AS s
         ON s.source_barcode = tx.t_tox21_id
         WHERE tx.t_original_sample_id IS NULL ;")

  #This section enters 9045 bottles
  ActiveRecord::Base.connection.execute("INSERT INTO #{schema}.bottles(stripped_barcode, coa_summary_id, created_at, updated_at)
         SELECT cs.bottle_barcode, cs.id, now(), now()
         FROM #{schema}.coa_summaries AS cs
         INNER JOIN #{schema}.tox_21_chemicals AS tx
         ON CONCAT(tx.t_tox21_id, '_legacy') = cs.bottle_barcode
         WHERE tx.t_original_sample_id IS NULL;")

  puts "Linking chemtrack.bottles with chemtrack.vial_details"
  ActiveRecord::Base.connection.execute("update #{schema}.vial_details AS vd
         INNER JOIN #{schema}.bottles AS b
         ON vd.source_barcode = b.stripped_barcode
         set vd.bottle_id = b.id;")

  puts "Linking chemtrack.plate_details to chemtrack.shipment_files"

  ActiveRecord::Base.connection.execute("UPDATE #{schema}.plate_details AS pd
         INNER JOIN #{schema}.plates AS p
         ON pd.aliquot_plate_barcode = p.aliquot_plate_barcode
         INNER JOIN #{schema}.shipment_files AS sf
         ON p.ship_id = sf.ship_id
         SET pd.shipment_file_id = sf.id;")

  puts "Linking chemtrack.vial_details to chemtrack.shipment_files"

  ActiveRecord::Base.connection.execute("UPDATE #{schema}.vial_details AS vd
         INNER JOIN #{schema}.plates AS p
         ON vd.aliquot_plate_barcode = p.aliquot_plate_barcode
         INNER JOIN #{schema}.shipment_files AS sf
         ON p.ship_id = sf.ship_id
         SET vd.shipment_file_id = sf.id;")

  ActiveRecord::Base.connection.execute("UPDATE #{schema}.shipment_files AS sf
         INNER JOIN #{schema}.vial_details AS vd
         ON vd.shipment_file_id = sf.id
         SET sf.vial = 1;")

  puts "Mapping CoaSummaries to Source Substance, Source Generic Substance Mapping, and Generic Substance "


  ActiveRecord::Base.connection.execute("INSERT INTO #{dsstox_schema}.source_substances (fk_chemical_list_id, dsstox_record_id, external_id, created_by, updated_by, created_at, updated_at)
  SELECT (SELECT MAX(id) FROM #{dsstox_schema}.chemical_lists),
     'test',
      coa.id,
     'rruizvev',
     'rruizvev',
     coa.created_at,
     coa.updated_at
     FROM #{schema}.coa_summaries AS coa
     INNER JOIN #{schema}.bottles AS b
     ON b.stripped_barcode = coa.bottle_barcode
     WHERE coa.source_substance_id IS NULL;")

  ActiveRecord::Base.connection.execute("UPDATE #{schema}.coa_summaries AS coa
     INNER JOIN #{dsstox_schema}.source_substances AS ss
     ON ss.external_id = coa.id
     SET coa.source_substance_id = ss.id,
     coa.chemical_list_id = ss.fk_chemical_list_id
     WHERE coa.source_substance_id IS NULL
     AND coa.chemical_list_id = ss.fk_chemical_list_id;")


  ##Insert into source_susbtance_identifiers for CASRN type
  ActiveRecord::Base.connection.execute("INSERT INTO #{dsstox_schema}.source_substance_identifiers (fk_source_substance_id, identifier, identifier_type, created_by, updated_by, created_at, updated_at)
    SELECT ss.id,
    (CASE WHEN coa.coa_casrn IS NOT NULL THEN coa.coa_casrn ELSE b.cas END) AS identifier,
    'CASRN',
    'rruizvev',
    'rruizvev',
    coa.created_at,
    coa.updated_at
    FROM  #{dsstox_schema}.source_substances AS ss
    INNER JOIN #{schema}.coa_summaries AS coa
    ON coa.id = ss.external_id
    INNER JOIN #{schema}.bottles AS b
    ON b.stripped_barcode = coa.bottle_barcode
    WHERE
    ss.fk_chemical_list_id = coa.chemical_list_id;")

  ##Insert into source_susbtance_identifiers for NAME type
  ActiveRecord::Base.connection.execute("INSERT INTO #{dsstox_schema}.source_substance_identifiers (fk_source_substance_id, identifier, identifier_type, created_by, updated_by, created_at, updated_at)
    SELECT ss.id,
    (CASE WHEN coa.coa_chemical_name IS NOT NULL THEN coa.coa_chemical_name ELSE b.compound_name END) AS identifier,
    'NAME',
    'rruizvev',
    'rruizvev',
    coa.created_at,
    coa.updated_at
    FROM #{dsstox_schema}.source_substances AS ss
    INNER JOIN #{schema}.coa_summaries AS coa
    ON coa.id = ss.external_id
    INNER JOIN #{schema}.bottles AS b
    ON b.stripped_barcode = coa.bottle_barcode
    WHERE
    ss.fk_chemical_list_id = coa.chemical_list_id;")

  ##Insert into source_susbtance_identifiers for BOTTLE type
  ActiveRecord::Base.connection.execute("INSERT INTO #{dsstox_schema}.source_substance_identifiers (fk_source_substance_id, identifier, identifier_type, created_by, updated_by, created_at, updated_at)
    SELECT ss.id,
    coa.bottle_barcode,
    'BOTTLE',
    'rruizvev',
    'rruizvev',
    coa.created_at,
    coa.updated_at
    FROM #{dsstox_schema}.source_substances  AS ss
    INNER JOIN #{schema}.coa_summaries AS coa
    ON coa.id = ss.external_id
    AND
    ss.fk_chemical_list_id = coa.chemical_list_id;")


  ActiveRecord::Base.connection.execute("INSERT INTO #{dsstox_schema}.source_generic_substance_mappings (fk_source_substance_id, fk_generic_substance_id, created_by, updated_by, created_at, updated_at)
     SELECT ss.id, coa.gsid, 'rruizvev', 'rruizvev', ss.created_at, ss.updated_at
     FROM #{dsstox_schema}.source_substances AS ss
     INNER JOIN #{schema}.coa_summaries AS coa
     ON coa.source_substance_id = ss.id
     INNER JOIN #{dsstox_schema}.generic_substances AS gs
     ON gs.id = coa.gsid")


  ActiveRecord::Base.connection.execute("set SQL_SAFE_UPDATES = 1;")
  ActiveRecord::Base.connection.execute("SET foreign_key_checks = 1;")

  puts "All set.. Yay!"

end

