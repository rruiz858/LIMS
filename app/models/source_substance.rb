class SourceSubstance < Dsstoxdb
  self.table_name = 'source_substances'
  self.primary_key = 'id'
  belongs_to :chemical_list, foreign_key: 'fk_chemical_list_id'
  has_one :source_generic_substance, dependent: :destroy, foreign_key: 'fk_source_substance_id'
  has_one :control, dependent: :destroy, foreign_key: 'source_substance_id'
  accepts_nested_attributes_for :control, update_only: true
  has_one :coa_summary, dependent: :destroy, foreign_key: 'source_substance_id'
  has_many :source_substance_identifiers, dependent: :destroy, foreign_key: 'fk_source_substance_id', primary_key: 'id'
  include DsstoxSchema



  def self.found_chemical(source_substance)
    if source_substance.source_generic_substance.blank?
      return false
    else
      return true
    end
  end

  def self.chemical_available(source_substance)
    results_hash = SourceSubstance.get_identifiers(source_substance)
    array_gsid = SourceSubstance.get_gsid(results_hash["CASRN"], results_hash["DTXSID"], results_hash["BOTTLE_ID"], results_hash["SAMPLE_ID"])
    if array_gsid.empty?
      return false
    else
      return true
    end
  end

  def self.multiple_gsid(source_substance)
    results_hash = SourceSubstance.get_identifiers(source_substance)
    array_gsid = SourceSubstance.get_gsid(results_hash["CASRN"], results_hash["DTXSID"], results_hash["BOTTLE_ID"], results_hash["SAMPLE_ID"])
    if array_gsid.blank?
      source_generic_substance = source_substance.source_generic_substance
      unless source_generic_substance.blank?
        return false
      else
        return "No GSID was found"
      end
      return " No GSID was found"
    elsif array_gsid.uniq.length > 1
      return true
    elsif array_gsid.uniq.length == 1
      return false
    end
  end

  def self.gsid(source_substance)
    unless source_substance.source_generic_substance.nil?
      return source_substance.source_generic_substance.generic_substance.id
    else
      return nil
    end
  end

  def self.dsstox_mapping(source_substance)
   results_hash = SourceSubstance.get_identifiers(source_substance)
   array_gsid = SourceSubstance.get_gsid(results_hash["CASRN"], results_hash["DTXSID"], results_hash["BOTTLE_ID"], results_hash["SAMPLE_ID"])
   unless array_gsid.blank?
      compact_array = array_gsid.compact #This removes the nil index values in array
      @generic_substance = GenericSubstance.find(compact_array.first)
      if compact_array.uniq.length > 1
      @mapping= SourceGenericSubstance.new(fk_source_substance_id: source_substance.id, fk_generic_substance_id: @generic_substance.id, connection_reason: "Multiple GSIDS", created_by: source_substance.created_by, updated_by: source_substance.updated_by)
      @mapping.save
      elsif compact_array.uniq.length == 1
        @mapping= SourceGenericSubstance.new(fk_source_substance_id: source_substance.id, fk_generic_substance_id: @generic_substance.id, connection_reason: "ONE GSID", created_by: source_substance.created_by, updated_by: source_substance.updated_by)
        @mapping.save
      end
    end
  end
  def self.get_identifiers(source_substance)
    identifier_hash = {"CASRN" => "", "DTXSID" => "", "BOTTLE_ID" => "", "SAMPLE_ID" => ""}
    source_substance.source_substance_identifiers.each do |identifier|
      identifier_hash.each { |key, value|
        if identifier.identifier_type == key
          identifier_hash[key] = identifier.identifier
        end }
    end
    return identifier_hash
  end

  def self.get_gsid(casrn, dtxsid, bottle_id, sample_id)
    array_gsid = []
    unless casrn.blank?
      @generic_substance_id = GenericSubstance.find_by_casrn(casrn)
      unless @generic_substance_id.blank?
        array_gsid.push(@generic_substance_id.id)
      end
    end
    unless dtxsid.blank?
      @generic_substance_dtxsid = GenericSubstance.find_by_dsstox_substance_id(dtxsid)
      unless @generic_substance_dtxsid.blank?
        array_gsid.push(@generic_substance_dtxsid.id)
      end
    end
    unless bottle_id.blank?
      @bottle = Bottle.find_by_stripped_barcode(bottle_id)
      unless @bottle.blank?
        @bottle_gsid = @bottle.coa_summary.gsid
        unless @bottle_gsid.blank?
          array_gsid.push(@bottle.coa_summary.gsid)
        end
      end
    end
    unless sample_id.blank?
      @plate_detail = PlateDetail.find_by_blinded_sample_id(sample_id)
      unless @plate_detail.blank?
        bottle = Bottle.find(@plate_detail.bottle_id)
        unless bottle.coa_summary_id.blank?
          array_gsid.push(bottle.coa_summary.gsid)
        end
      end
    end
    return array_gsid
    array_gsid = Array.new
  end



  def self.list_insert(old_chemical_list, new_chemical_list, user, order)
    SourceSubstance.database_connectivity
    #Insert into source substance
    @connection.execute("INSERT INTO #{@schema_hash[:ss]}(fk_chemical_list_id, dsstox_record_id, external_id, created_by, updated_by, created_at, updated_at)
    SELECT #{new_chemical_list.id},'test', old_ss.id, '#{user}', '#{user}', NOW(), NOW()
    FROM #{@schema_hash[:ss]} AS old_ss
    WHERE old_ss.fk_chemical_list_id = #{old_chemical_list.id};")

    #Insert into source substance identifiers
    @connection.execute("INSERT INTO #{@schema_hash[:ssi]} (fk_source_substance_id, identifier, identifier_type, created_by, updated_by, created_at, updated_at)
    SELECT new_ss.id, ssi.identifier, ssi.identifier_type, '#{user}', '#{user}', NOW(), NOW()
    FROM #{@schema_hash[:ssi]} AS ssi
    INNER JOIN #{@schema_hash[:ss]} AS new_ss
    ON new_ss.external_id = ssi.fk_source_substance_id
    WHERE new_ss.fk_chemical_list_id = #{new_chemical_list.id}
    AND new_ss.id NOT IN (SELECT old_ssi.fk_source_substance_id
                          FROM #{@schema_hash[:ssi]} AS old_ssi);")

    #Insert into source generic mappings
    @connection.execute("INSERT INTO #{@schema_hash[:sgm]} (fk_source_substance_id, fk_generic_substance_id, connection_reason, created_by, updated_by, created_at, updated_at)
    SELECT new_ss.id, sgm.fk_generic_substance_id, sgm.connection_reason,'#{user}', '#{user}', NOW(), NOW()
    FROM #{@schema_hash[:ss]} AS new_ss
    INNER JOIN #{@schema_hash[:sgm]} AS sgm
    ON sgm.fk_source_substance_id = new_ss.external_id
    WHERE new_ss.fk_chemical_list_id = #{new_chemical_list.id}
    AND new_ss.id NOT IN (SELECT old_sgm.fk_source_substance_id
                          FROM #{@schema_hash[:sgm]} AS old_sgm);")

  end

  def self.available(chemical_list_id, order_amount, order_concentration)
    SourceSubstance.database_connectivity
    if order_concentration == 20 || order_concentration == 100
      SourceSubstance.find_by_sql("SELECT
         ss.id,
         gs.dsstox_substance_id AS dtxsid,
         gs.casrn as cas,
         gs.preferred_name as name,
         sum(b.qty_available_mg_ul) AS bottle_amount,
         b.units AS unit,
          (CASE when c.controls = 0 then 0
                when c.controls IS NULL then 0
                else 1
         end) AS control,
         (CASE when sgm.connection_reason = 'Multiple GSIDS' then true else '' end) AS multiple,
         gs.id AS gsid,
         c.standard_replicate AS replicate
         FROM #{@schema_hash[:ss]} AS ss
         LEFT JOIN #{@database}.controls AS c
         ON c.source_substance_id = ss.id
         INNER JOIN #{@schema_hash[:sgm]} AS sgm
         ON sgm.fk_source_substance_id = ss.id
         INNER JOIN #{@schema_hash[:gs]} AS gs
         ON sgm.fk_generic_substance_id = gs.id
         INNER JOIN #{@database}.coa_summaries AS coa
         ON coa.gsid = gs.id
         INNER JOIN #{@database}.bottles AS b
         ON coa.id = b.coa_summary_id
         WHERE
         ss.fk_chemical_list_id = #{chemical_list_id}
         AND b.concentration_mm BETWEEN #{order_concentration - 1 } AND #{order_concentration + 1}
         GROUP BY ss.id
         HAVING SUM(b.qty_available_mg_ul) > #{order_amount};")
    else
      SourceSubstance.find_by_sql("SELECT
         ss.id,
         gs.dsstox_substance_id AS dtxsid,
         gs.casrn as cas,
         gs.preferred_name as name,
         sum(b.qty_available_mg_ul) AS bottle_amount,
         b.units AS unit,
         (CASE when c.controls = 0 then 0
               when c.controls IS NULL then 0
               else 1
         end) AS control,
         (CASE when sgm.connection_reason = 'Multiple GSIDS' then true else '' end) AS multiple,
         sgm.fk_generic_substance_id AS gsid,
         c.standard_replicate AS replicate
         FROM #{@schema_hash[:ss]} AS ss
         LEFT JOIN #{@database}.controls AS c
         ON c.source_substance_id = ss.id
         INNER JOIN #{@schema_hash[:sgm]} AS sgm
         ON sgm.fk_source_substance_id = ss.id
         INNER JOIN #{@schema_hash[:gs]} AS gs
         ON sgm.fk_generic_substance_id = gs.id
         INNER JOIN #{@database}.coa_summaries AS coa
         ON coa.gsid = gs.id
         INNER JOIN #{@database}.bottles AS b
         ON coa.id = b.coa_summary_id
         WHERE
         ss.fk_chemical_list_id = #{chemical_list_id}
         AND b.concentration_mm IS NULL  AND
         b.qty_available_mg_ul IS NOT NULL
         GROUP BY ss.id
         HAVING SUM(b.qty_available_mg_ul) > #{order_amount};")
    end
  end

  def self.available_and_controls(chemical_list_id, order_amount, order_concentration, order_id)
   available = SourceSubstance.available(chemical_list_id, order_amount, order_concentration)
   ss_id = available.map(&:'id')
   control = Control.new.not_found_in_available(order_id, ss_id)
   available + control
  end

  def self.no_hits(chemical_list_id)
    SourceSubstance.database_connectivity
    SourceSubstance.find_by_sql("SELECT *
    FROM #{@schema_hash[:ss]} AS ss
    WHERE
    ss.fk_chemical_list_id = #{chemical_list_id}
    AND
    ss.id NOT IN ( SELECT sgm.fk_source_substance_id
    FROM #{@schema_hash[:sgm]} AS sgm);")
  end

  def self.not_available(chemical_list_id, order_amount, order_concentration)
    SourceSubstance.database_connectivity
    if order_concentration == 20 || order_concentration == 100
      SourceSubstance.find_by_sql("SELECT
          ss.id AS id,
          gs.dsstox_substance_id AS dtxsid,
          gs.casrn as cas,
          gs.preferred_name as name,
          gs.id AS gsid,
          (CASE when sgm.connection_reason = 'Multiple GSIDS' then true else '' end) AS multiple,
          ss.created_at AS created_at,
          ss.created_by AS created_by
          FROM #{@schema_hash[:ss]} AS ss
          INNER JOIN #{@schema_hash[:sgm]} AS sgm
          ON sgm.fk_source_substance_id = ss.id
          INNER JOIN #{@schema_hash[:gs]} AS gs
          ON sgm.fk_generic_substance_id = gs.id
          WHERE  ss.fk_chemical_list_id = #{chemical_list_id}
          AND
          ss.id NOT IN (
          SELECT ss.id
          FROM #{@schema_hash[:ss]} AS ss
          INNER JOIN #{@schema_hash[:sgm]} AS sgm
          ON sgm.fk_source_substance_id = ss.id
          INNER JOIN #{@database}.coa_summaries AS coa
          ON coa.gsid = sgm.fk_generic_substance_id
          INNER JOIN #{@database}.bottles AS b
          ON coa.id = b.coa_summary_id
          WHERE
          ss.fk_chemical_list_id = #{chemical_list_id}
          AND b.concentration_mm BETWEEN #{order_concentration - 1 } AND #{order_concentration + 1}
          GROUP BY ss.id
          HAVING SUM(b.qty_available_mg_ul) > #{order_amount});")
    else
      SourceSubstance.find_by_sql("SELECT
          ss.id AS id,
          gs.dsstox_substance_id AS dtxsid,
          gs.casrn as cas,
          gs.id AS gsid,
          gs.preferred_name as name,
          (CASE when sgm.connection_reason = 'Multiple GSIDS' then true else '' end) AS multiple,
          ss.created_at AS created_at,
          ss.created_by AS created_by
          FROM #{@schema_hash[:ss]} AS ss
          INNER JOIN #{@schema_hash[:sgm]} AS sgm
          ON sgm.fk_source_substance_id = ss.id
          INNER JOIN #{@schema_hash[:gs]} AS gs
          ON sgm.fk_generic_substance_id = gs.id
          WHERE  ss.fk_chemical_list_id = #{chemical_list_id}
          AND
          ss.id NOT IN (
          SELECT ss.id
          FROM #{@schema_hash[:ss]} AS ss
          INNER JOIN #{@schema_hash[:sgm]} AS sgm
          ON sgm.fk_source_substance_id = ss.id
          INNER JOIN #{@database}.coa_summaries AS coa
          ON coa.gsid = sgm.fk_generic_substance_id
          INNER JOIN #{@database}.bottles AS b
          ON coa.id = b.coa_summary_id
          WHERE
          ss.fk_chemical_list_id = #{chemical_list_id}
          AND b.concentration_mm IS NULL
          AND b.qty_available_mg_ul IS NOT NULL
          GROUP BY ss.id
          HAVING SUM(b.qty_available_mg_ul) > #{order_amount});")
    end
  end

  def self.duplicates(chemical_list_id)
    SourceSubstance.database_connectivity
    SourceSubstance.find_by_sql("SELECT ss.id AS id, ss.created_by AS created_by, ss.dsstox_record_id AS dsstox_record_id, sgm.fk_generic_substance_id AS gsid, COUNT(*) AS count
                                 FROM #{@schema_hash[:ss]} AS ss
                                 INNER JOIN #{@schema_hash[:sgm]} AS sgm
                                 ON sgm.fk_source_substance_id = ss.id
                                 WHERE ss.fk_chemical_list_id = #{chemical_list_id}
                                 GROUP BY gsid
                                 HAVING COUNT(*) >1;")
  end

  def self.database_connectivity
    @schema_hash = database_initialization
    @config = Rails.configuration.database_configuration
    @database = @config[Rails.env]["database"]
    @connection = ActiveRecord::Base.connection
  end

end
