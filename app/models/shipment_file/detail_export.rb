class ShipmentFile::DetailExport
  include OpenExcel
  attr_reader :shipment_file, :headers, :spreadsheet

  def initialize(args ={})
    @shipment_file = ShipmentFile.find(args[:shipment_file])
    @spreadsheet = @shipment_file.spreadsheet
    @headers = @shipment_file.headers(@spreadsheet)
    @vial = @shipment_file.vial?
    @mixture = @shipment_file.mixture?
  end

  def insert_details_transaction
    config = Rails.configuration.database_configuration
    chemtrack_database = config[Rails.env]["database"] #returns a hash to make sure it's using the current version of ChemTrack
    connection = ActiveRecord::Base.connection #utilizes the current connection
    shipment_tmp = "#{chemtrack_database}.shipment_tmp_table_#{Time.now.to_i}"
    @errors = Array.new
    begin
      create_tmp(connection, shipment_tmp)
      insert_into_tmp(connection, shipment_tmp, detail_string = populate_insert_strings) #distinguishes between vials and plate details
      validate_tmp_contents(connection, shipment_tmp, chemtrack_database)
      if @errors.empty? #populates @error object
        #insert into plate/vial details
        insert_into_details(chemtrack_database, detail_table_kind, connection, shipment_tmp)
        insert_concats(chemtrack_database, detail_table_kind, connection, shipment_tmp)
        @mapped_other = mapped_other(@shipment_file.id)
      else
        @shipment_file.destroy #error with shipment file's content
      end
    rescue => e #check for errors in database, uses same @error object as other validations
      return {valid: false, errors: @errors.push(e)}
    ensure
      connection.execute("DROP TABLE #{shipment_tmp};")
    end
    if !@errors.empty?
      {valid: false, errors: @errors}
    else
      {valid: true, mapped_other: @mapped_other}
    end
  end

  private

  def insert_into_details(chemtrack, detail_kind, connection, shipment_tmp)
    connection.execute("INSERT INTO #{chemtrack}.#{detail_kind}
                        (#{select_columns << ', created_at, updated_at, bottle_id'})
                        SELECT #{format_columns_for_inserts << ', tmp.created_at, tmp.updated_at, b.id'}
                        FROM #{shipment_tmp} as tmp
                        INNER JOIN  #{chemtrack}.bottles as b
                          ON tmp.source_barcode = b.stripped_barcode
                          OR tmp.solubilized_barcode = b.stripped_barcode
                          OR tmp.lts_barcode = b.stripped_barcode
                        GROUP by (tmp.id);")
  end

  def insert_concats(chemtrack, detail_kind, connection, shipment_tmp)
    connection.execute("INSERT INTO #{chemtrack}.#{detail_kind}
                        (#{select_columns << ', created_at, updated_at, mapped_other, bottle_id'})
                        SELECT #{format_columns_for_inserts << ', tmp.created_at, tmp.updated_at, 1, b.id'}
                        FROM #{shipment_tmp} as tmp
                        INNER JOIN  #{chemtrack}.bottles as b
                        ON tmp.concat_source_barcode = b.stripped_barcode
                        OR tmp.concat_solubilized_barcode = b.stripped_barcode
                        OR tmp.concat_lts_barcode = b.stripped_barcode
                        LEFT OUTER JOIN #{chemtrack}.bottles as b2
                        ON (tmp.source_barcode = b2.stripped_barcode
                        OR tmp.solubilized_barcode = b2.stripped_barcode
                        OR tmp.lts_barcode = b2.stripped_barcode)
                        WHERE b2.id IS NULL
                        GROUP by (tmp.id);")
  end

  def format_columns_for_inserts
    select_columns.split(',').each{|column| column.prepend('tmp.').strip}.join(",")
  end

  def create_tmp(connection, shipment_tmp)
    connection.execute("CREATE TEMPORARY TABLE #{shipment_tmp}(
                          id int NOT NULL AUTO_INCREMENT,
                          ism TEXT,
                          sample_id VARCHAR(255),
                          structure_id VARCHAR(255),
                          structure_real_amw VARCHAR(255),
                          sample_supplier VARCHAR(255),
                          supplier_structure_id VARCHAR(255),
                          aliquot_well_id VARCHAR(255),
                          aliquot_plate_barcode VARCHAR(255),
                          aliquot_solvent VARCHAR(255),
                          aliquot_conc VARCHAR(255),
                          aliquot_conc_unit VARCHAR(255),
                          aliquot_amount VARCHAR(255),
                          aliquot_amount_unit VARCHAR(255),
                          aliquot_volume VARCHAR(255),
                          aliquot_volume_unit VARCHAR(255),
                          aliquot_vial_barcode VARCHAR(255),
                          purity VARCHAR(255),
                          purity_method VARCHAR(255),
                          sample_appearance VARCHAR(255),
                          structure_name VARCHAR(255),
                          cas_regno VARCHAR(255),
                          supplier_sample_id VARCHAR(255),
                          aliquot_date VARCHAR(255),
                          solubilized_barcode VARCHAR(255),
                          lts_barcode VARCHAR(255),
                          source_barcode VARCHAR(255),
                          concat_solubilized_barcode VARCHAR(255),
                          concat_lts_barcode VARCHAR(255),
                          concat_source_barcode VARCHAR(255),
                          blinded_sample_id VARCHAR(255),
                          created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          shipment_file_id int,
                          PRIMARY KEY(ID),
                          INDEX (source_barcode),
                          INDEX (solubilized_barcode),
                          INDEX (lts_barcode),
                          INDEX (concat_solubilized_barcode),
                          INDEX (concat_lts_barcode),
                          INDEX (concat_source_barcode),
                          INDEX (blinded_sample_id),
                          INDEX (shipment_file_id)
                          );")
    connection.execute("ALTER TABLE #{shipment_tmp} CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci;")
  end

  def insert_into_tmp(connection, shipment_tmp, detail_string)
    connection.execute("INSERT INTO #{shipment_tmp} (#{select_columns << ',concat_solubilized_barcode, concat_lts_barcode,
                        concat_source_barcode'}) VALUES #{detail_string}")
  end

  def populate_insert_strings #this string creates a string that will be used in the addition of records in tmp table =
    details = ""
    @vial ? method= :vial_string : method = :plate_string
    (2..@spreadsheet.last_row).each_with_index do |j, i|
      row = Hash[[@headers, @spreadsheet.row(j)].transpose]
      row.each { |k, v| row[k]= 'momLlammaNullNull'if v.blank? ; row[k] = row[k].to_s }
      i == 0 ? details << send(method, row) : details << ', ' << send(method, row)  #last attribute in loop does not need , example ('mom','dad'),('jenn', 'jon')
    end
    details.gsub(/"momLlammaNullNull"+/, 'NULL')
  end

  def select_columns
    if @vial
      string ='ism, sample_id, structure_id,
        structure_real_amw, sample_supplier,
        supplier_structure_id, aliquot_plate_barcode,
        aliquot_vial_barcode, aliquot_amount, aliquot_amount_unit,
        sample_appearance, purity, purity_method, structure_name, cas_regno,
        supplier_sample_id, aliquot_date, solubilized_barcode,
        lts_barcode, source_barcode,
        blinded_sample_id, shipment_file_id'
      @headers.include?('aliquot_well_id') ? string << ',aliquot_well_id' : string
    else
       'ism, sample_id, structure_id, structure_real_amw, sample_supplier,
        supplier_structure_id, aliquot_plate_barcode,
        aliquot_solvent, aliquot_conc, aliquot_conc_unit,
        aliquot_volume, aliquot_volume_unit,
        sample_appearance, structure_name, cas_regno,
        supplier_sample_id, aliquot_date, solubilized_barcode,
        lts_barcode, source_barcode,  blinded_sample_id,
        shipment_file_id, aliquot_well_id'
    end
  end

  def plate_string(row)
    "( #{'"'<<row['ism']<<'"'},
       #{'"'<<row['sample_id']<<'"'},
       #{'"'<<row['structure_id']<<'"'},
       #{'"'<<row['structure_real_amw']<<'"'},
       #{'"'<<row['sample_supplier']<<'"'},
       #{'"'<<row['supplier_structure_id']<<'"'},
       #{'"'<<row['aliquot_plate_barcode']<<'"'},
       #{'"'<<row['aliquot_solvent']<<'"'},
       #{'"'<<row["aliquot_conc"]<<'"'},
       #{'"'<<row["aliquot_conc_unit"]<<'"'},
       #{'"'<<row['aliquot_volume']<<'"'},
       #{'"'<<row['aliquot_volume_unit']<<'"'},
       #{'"'<<row['sample_appearance']<<'"'},
       #{'"'<<row['structure_name']<<'"'},
       #{'"'<<row['cas_regno']<<'"'},
       #{'"'<<row['supplier_sample_id']<<'"'},
       #{'"'<<row['aliquot_date']<<'"'},
       #{'"'<<row['solubilized_barcode']<<'"'},
       #{'"'<<row['lts_barcode']<<'"'},
       #{'"'<<row['source_barcode']<<'"'},
       #{'"'<< blinded_sample_id(row['aliquot_plate_barcode'], row['aliquot_well_id'])<<'"'},
       #{@shipment_file.id},
       #{'"'<<row['aliquot_well_id']<<'"'},
       #{'"'<<concat_barcodes(row['solubilized_barcode'])<<'"'},
       #{'"'<<concat_barcodes(row['lts_barcode'])<<'"'},
       #{'"'<<concat_barcodes(row['source_barcode'])<<'"'})"
  end


  def vial_string(row)
    string = "( #{'"'<<row['ism']<<'"'},
       #{'"'<<row['sample_id']<<'"'},
       #{'"'<<row['structure_id']<<'"'},
       #{'"'<<row['structure_real_amw']<<'"'},
       #{'"'<<row['sample_supplier']<<'"'},
       #{'"'<<row['supplier_structure_id']<<'"'},
       #{'"'<<row['aliquot_plate_barcode']<<'"'},
       #{'"'<<row['aliquot_vial_barcode']<<'"'},
       #{'"'<<row['aliquot_amount']<<'"'},
       #{'"'<<row['aliquot_amount_unit']<<'"'},
       #{'"'<<row['sample_appearance']<<'"'},
       #{'"'<<row['purity']<<'"'},
       #{'"'<<row['purity_method']<<'"'},
       #{'"'<<row['structure_name']<<'"'},
       #{'"'<<row['cas_regno']<<'"'},
       #{'"'<<row['supplier_sample_id']<<'"'},
       #{'"'<<row['aliquot_date']<<'"'},
       #{'"'<<row['solubilized_barcode']<<'"'},
       #{'"'<<row['lts_barcode']<<'"'},
       #{'"'<<row['source_barcode']<<'"'},
       #{'"'<< blinded_sample_id(row['aliquot_plate_barcode'], row['aliquot_vial_barcode'])<<'"'},
       #{@shipment_file.id}"
       @headers.include?("aliquot_well_id") ? string << ",#{row['aliquot_well_id']}," : string << ','
       string << "#{'"'<<concat_barcodes(row['solubilized_barcode'])<<'"'},
                  #{'"'<<concat_barcodes(row['lts_barcode'])<<'"'},
                  #{'"'<<concat_barcodes(row['source_barcode'])<<'"'})"
    string
  end


  def blinded_sample_id(plate_barcode, id)
    unless (plate_barcode && id).nil?
      @vial ? plate_barcode + "_" + id.to_s : plate_barcode + id.to_s
    end
  end

  def concat_barcodes(barcode_kind)
    unless barcode_kind.nil?
      "0#{barcode_kind}"
    end
  end

  def validate_tmp_contents(connection, tmp_table, chemtrack)
    @connection = connection
    @tmp_table = tmp_table
    @chemtrack = chemtrack
    validate_blinded_sample_ids
    presence_of_sample_ids
    unless @mixture
        validate_duplicates_in_tmp
    end
    validate_units
    validate_presence_of_barcodes
    validate_all_barcodes
  end

  def mapped_other(id)
    @vial ? VialDetail.where('shipment_file_id = ? AND mapped_other = ?', id, 1)
    : PlateDetail.where('shipment_file_id = ? AND mapped_other = ?', id, 1)
  end

  def detail_table_kind
    @vial ? 'vial_details' : 'plate_details'
  end

  def validate_units
    error_string = ''
    if @vial
      wrong_units = @connection.execute("SELECT tmp.aliquot_amount_unit from #{@tmp_table} as tmp
                                         WHERE NOT EXISTS (
                                         SELECT vd.aliquot_amount_unit from #{@chemtrack}.vial_details as vd
                                         WHERE  vd.aliquot_amount_unit = tmp.aliquot_amount_unit);")
      correct_units = @connection.execute("SELECT vd.aliquot_amount_unit from #{@chemtrack}.vial_details as vd")
    else
      wrong_units = @connection.execute("SELECT tmp.aliquot_conc_unit, tmp.aliquot_volume_unit from #{@tmp_table} as tmp
                                         WHERE NOT EXISTS (
                                         SELECT pd.aliquot_conc_unit, pd.aliquot_volume_unit  from #{@chemtrack}.plate_details as pd
                                         WHERE pd.aliquot_conc_unit = tmp.aliquot_conc_unit AND pd.aliquot_volume_unit  = tmp.aliquot_volume_unit );")
      correct_units = @connection.execute("SELECT pd.aliquot_conc_unit, pd.aliquot_volume_unit  from #{@chemtrack}.plate_details as pd")
    end
    format_unit_error_string(wrong_units, correct_units, error_string)
    any_errors(error_string, "The following units are not allowed")
  end

  def format_unit_error_string(wrong_units, correct_units, string)
      wrong_units.each {|unit|  string << unit.first + "\n" unless correct_units.map(&:first).include? unit.first
      ; string << unit.second + "\n" unless correct_units.map(&:second).include? unit.second}

  end

  def validate_blinded_sample_ids
    error_string = ''
    duplicates_in_database = @connection.execute("SELECT tmp.blinded_sample_id FROM #{@tmp_table} as tmp
                                                  INNER JOIN #{@chemtrack}.#{detail_table_kind} as detail
                                                    ON tmp.blinded_sample_id = detail.blinded_sample_id;")
    duplicates_in_database.each { |sample_id| error_string << sample_id.first + "\n" }
    any_errors(error_string, "These Blinded Sample Ids are not unique")
  end

  def presence_of_sample_ids
    error_string = ''
    query = @connection.execute("SELECT COUNT(tmp.id) FROM #{@tmp_table} as tmp
                                            WHERE tmp.blinded_sample_id LIKE '%Null%';")
    count = query.first.first
    error_string << "#{count}" if count.to_i > 0
    any_errors(error_string, "Number of rows without blinded_sample_ids")
  end

  def validate_duplicates_in_tmp
    error_string = ''
    duplicates_in_file = @connection.execute("SELECT tmp.blinded_sample_id FROM #{@tmp_table} as tmp
                                                 GROUP BY blinded_sample_id HAVING COUNT(*) > 1;")
    duplicates_in_file.each { |sample_id| error_string << sample_id.first + "\n" }
    any_errors(error_string, "The following Blinded Sample Ids are duplicated within the file")
  end

  def validate_all_barcodes
    error_string = ''
    no_match_query = @connection.execute("SELECT tmp.source_barcode, tmp.solubilized_barcode, tmp.lts_barcode
                                          FROM #{@tmp_table} as tmp
                                          LEFT OUTER JOIN #{@chemtrack}.bottles as b
                                            ON tmp.source_barcode = b.stripped_barcode
                                            OR tmp.solubilized_barcode = b.stripped_barcode
                                            OR tmp.lts_barcode= b.stripped_barcode
                                            OR tmp.concat_solubilized_barcode = b.stripped_barcode
                                            OR tmp.concat_source_barcode = b.stripped_barcode
                                            OR tmp.concat_lts_barcode = b.stripped_barcode
                                          WHERE b.id IS NULL;")
    no_match_query.each { |barcode| barcode.find { |x| error_string << x + "\n"  unless x.blank? } }
    any_errors(error_string, "These Barcodes do not exist or are not curated")
  end

  def validate_presence_of_barcodes
    error_string = ''
    query = @connection.execute("SELECT COUNT(tmp.id) FROM #{@tmp_table} as tmp
                                            WHERE tmp.solubilized_barcode IS NULL
                                            AND tmp.source_barcode IS NULL
                                            AND tmp.lts_barcode IS NULL;")
    count = query.first.first
    error_string << "#{count}" if count.to_i > 0
    any_errors(error_string, "Number of rows without any barcodes")
  end

  def any_errors(error_string, message)
    unless error_string.empty?
      @errors.push("#{message}: #{error_string}")
    end
  end

end