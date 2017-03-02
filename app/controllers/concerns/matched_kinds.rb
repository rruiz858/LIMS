require 'mysql2'
module MatchedKinds
  extend ActiveSupport::Concern
  included do
    before_action :set_chemical_list_id
    include DsstoxSchema
  end


  def casrn_name
    schema_hash = database_initialization
    config = Rails.configuration.database_configuration
    chemtrack_database = config[Rails.env]["database"]
    SourceSubstance.find_by_sql("SELECT SQL_CACHE distinct(ss.id) AS id,
    sgm.connection_reason,
    (SELECT ssi.identifier FROM #{schema_hash[:ssi]} as ssi where ssi.identifier_type = 'NAME' AND ssi.fk_source_substance_id = ss.id LIMIT 1) AS SOURCENAME,
    (SELECT ssi.identifier FROM #{schema_hash[:ssi]} as ssi where ssi.identifier_type = 'CASRN' AND ssi.fk_source_substance_id = ss.id LIMIT 1) AS SOURCECASRN,
    sgm.fk_generic_substance_id AS GSID,
    gs.preferred_name AS preferred_name,
    gs.casrn AS CASRN,
    coa.bottle_barcode AS BARCODE,
    sgm.created_at,
    (SELECT ssi.identifier FROM #{schema_hash[:ssi]} as ssi where ssi.identifier_type = 'NAME' AND ssi.fk_source_substance_id = ss.id LIMIT 1)=coa.coa_chemical_name as COA_NAME_NULL,
    (SELECT ssi.identifier FROM #{schema_hash[:ssi]} as ssi where ssi.identifier_type = 'CASRN' AND ssi.fk_source_substance_id = ss.id LIMIT 1)=coa.coa_casrn as COA_CASRN_NULL
    FROM #{schema_hash[:ss]} AS ss
    INNER JOIN #{schema_hash[:sgm]} AS sgm
    ON ss.id = sgm.fk_source_substance_id
    INNER JOIN #{schema_hash[:gs]} AS gs
    ON sgm.fk_generic_substance_id = gs.id
    INNER JOIN #{chemtrack_database}.coa_summaries AS coa
    ON ss.id = coa.source_substance_id
    WHERE ss.fk_chemical_list_id = #{@chemical_list.id}
    AND sgm.connection_reason like 'MATCHED BY CASRN AND NAME'
    AND sgm.curator_validated IS NULL; ")
  end

  def name_other
    schema_hash = database_initialization
    config = Rails.configuration.database_configuration
    chemtrack_database = config[Rails.env]["database"]
    SourceSubstance.find_by_sql("SELECT SQL_CACHE distinct(ss.id) AS id,
    sgm.connection_reason,
    (SELECT ssi.identifier FROM #{schema_hash[:ssi]} as ssi where ssi.identifier_type = 'NAME' AND ssi.fk_source_substance_id = ss.id LIMIT 1) AS SOURCENAME,
    (SELECT ssi.identifier FROM #{schema_hash[:ssi]} as ssi where ssi.identifier_type = 'CASRN' AND ssi.fk_source_substance_id = ss.id LIMIT 1) AS SOURCECASRN,
    sgm.fk_generic_substance_id AS GSID,
    gs.preferred_name AS preferred_name,
    gs.casrn AS CASRN,
    coa.bottle_barcode AS BARCODE,
    sgm.created_at,
    (SELECT ssi.identifier FROM #{schema_hash[:ssi]} as ssi where ssi.identifier_type = 'NAME' AND ssi.fk_source_substance_id = ss.id LIMIT 1)=coa.coa_chemical_name as COA_NAME_NULL,
    (SELECT ssi.identifier FROM #{schema_hash[:ssi]} as ssi where ssi.identifier_type = 'CASRN' AND ssi.fk_source_substance_id = ss.id LIMIT 1)=coa.coa_casrn as COA_CASRN_NULL
    FROM #{schema_hash[:ss]} AS ss
    INNER JOIN #{schema_hash[:sgm]} AS sgm
    ON ss.id = sgm.fk_source_substance_id
    INNER JOIN #{schema_hash[:gs]} AS gs
    ON sgm.fk_generic_substance_id = gs.id
    INNER JOIN #{chemtrack_database}.coa_summaries AS coa
    ON ss.id = coa.source_substance_id
    WHERE ss.fk_chemical_list_id = #{@chemical_list.id}
    AND sgm.connection_reason like 'MATCHED CASRN, NAME MATCHED OTHER'
    AND sgm.curator_validated IS NULL; ")
  end


  def name
    schema_hash = database_initialization
    config = Rails.configuration.database_configuration
    chemtrack_database = config[Rails.env]["database"]
    SourceSubstance.find_by_sql("SELECT SQL_CACHE distinct(ss.id) AS id,
    sgm.connection_reason,
    (SELECT ssi.identifier FROM #{schema_hash[:ssi]} as ssi where ssi.identifier_type = 'NAME' AND ssi.fk_source_substance_id = ss.id LIMIT 1) AS SOURCENAME,
    (SELECT ssi.identifier FROM #{schema_hash[:ssi]} as ssi where ssi.identifier_type = 'CASRN' AND ssi.fk_source_substance_id = ss.id LIMIT 1) AS SOURCECASRN,
    sgm.fk_generic_substance_id AS GSID,
    gs.preferred_name AS preferred_name,
    gs.casrn AS CASRN,
    coa.bottle_barcode AS BARCODE,
    sgm.created_at,
    (SELECT ssi.identifier FROM #{schema_hash[:ssi]} as ssi where ssi.identifier_type = 'NAME' AND ssi.fk_source_substance_id = ss.id LIMIT 1)=coa.coa_chemical_name as COA_NAME_NULL,
    (SELECT ssi.identifier FROM #{schema_hash[:ssi]} as ssi where ssi.identifier_type = 'CASRN' AND ssi.fk_source_substance_id = ss.id LIMIT 1)=coa.coa_casrn as COA_CASRN_NULL
    FROM #{schema_hash[:ss]} AS ss
    INNER JOIN #{schema_hash[:sgm]} AS sgm
    ON ss.id = sgm.fk_source_substance_id
    INNER JOIN #{schema_hash[:gs]} AS gs
    ON sgm.fk_generic_substance_id = gs.id
    INNER JOIN #{chemtrack_database}.coa_summaries AS coa
    ON ss.id = coa.source_substance_id
    WHERE ss.fk_chemical_list_id = #{@chemical_list.id}
    AND sgm.connection_reason like 'MATCHED NAME'
    AND sgm.curator_validated IS NULL; ")
  end

  def casrn
    schema_hash = database_initialization
    config = Rails.configuration.database_configuration
    chemtrack_database = config[Rails.env]["database"]
    SourceSubstance.find_by_sql("SELECT SQL_CACHE distinct(ss.id) AS id,
    sgm.connection_reason,
    (SELECT ssi.identifier FROM #{schema_hash[:ssi]} as ssi where ssi.identifier_type = 'NAME' AND ssi.fk_source_substance_id = ss.id LIMIT 1) AS SOURCENAME,
    (SELECT ssi.identifier FROM #{schema_hash[:ssi]} as ssi where ssi.identifier_type = 'CASRN' AND ssi.fk_source_substance_id = ss.id LIMIT 1) AS SOURCECASRN,
    sgm.fk_generic_substance_id AS GSID,
    gs.preferred_name AS preferred_name,
    gs.casrn AS CASRN,
    coa.bottle_barcode AS BARCODE,
    sgm.created_at,
    (SELECT ssi.identifier FROM #{schema_hash[:ssi]} as ssi where ssi.identifier_type = 'NAME' AND ssi.fk_source_substance_id = ss.id LIMIT 1)=coa.coa_chemical_name as COA_NAME_NULL,
    (SELECT ssi.identifier FROM #{schema_hash[:ssi]} as ssi where ssi.identifier_type = 'CASRN' AND ssi.fk_source_substance_id = ss.id LIMIT 1)=coa.coa_casrn as COA_CASRN_NULL
    FROM #{schema_hash[:ss]} AS ss
    INNER JOIN #{schema_hash[:sgm]} AS sgm
    ON ss.id = sgm.fk_source_substance_id
    INNER JOIN #{schema_hash[:gs]} AS gs
    ON sgm.fk_generic_substance_id = gs.id
    INNER JOIN #{chemtrack_database}.coa_summaries AS coa
    ON ss.id = coa.source_substance_id
    WHERE ss.fk_chemical_list_id = #{@chemical_list.id}
    AND sgm.connection_reason like 'MATCHED CASRN'
    AND sgm.curator_validated IS NULL; ")
  end

  def no_hits
    schema_hash = database_initialization
    config = Rails.configuration.database_configuration
    chemtrack_database = config[Rails.env]["database"]
    SourceSubstance.find_by_sql("SELECT SQL_CACHE distinct(ss.id) AS id,
    sgm.connection_reason,
    (SELECT ssi.identifier FROM #{schema_hash[:ssi]} as ssi where ssi.identifier_type = 'NAME' AND ssi.fk_source_substance_id = ss.id LIMIT 1) AS SOURCENAME,
    (SELECT ssi.identifier FROM #{schema_hash[:ssi]} as ssi where ssi.identifier_type = 'CASRN' AND ssi.fk_source_substance_id = ss.id LIMIT 1) AS SOURCECASRN,
    coa.bottle_barcode AS BARCODE,
    'N/A' AS GSID,
    'N/A' AS preferred_name,
    'N/A' AS CASRN,
    sgm.created_at
    FROM #{schema_hash[:ss]} AS ss
    INNER JOIN #{schema_hash[:sgm]} AS sgm
    ON ss.id = sgm.fk_source_substance_id
    INNER JOIN #{chemtrack_database}.coa_summaries AS coa
    ON ss.id = coa.source_substance_id
    WHERE ss.fk_chemical_list_id = #{@chemical_list.id}
    AND sgm.connection_reason like 'NO HIT'
    AND sgm.curator_validated IS NULL; ")
  end

  def coa_matches_query(ss_id)
    schema_hash = database_initialization
    config = Rails.configuration.database_configuration
    chemtrack_database = config[Rails.env]["database"]
    SourceSubstance.find_by_sql("SELECT SQL_CACHE MIN(sm.rank) AS SM_RANK, ss.id AS SSID, ssi.id AS SSIID, ssi.identifier AS IDENTIFIER, gs.preferred_name AS PREFERRED_NAME , gs.casrn AS CASRN, sm.fk_generic_substance_id AS GSID, coa.bottle_barcode AS BARCODE
    FROM #{schema_hash[:ss]} as ss
    INNER JOIN #{schema_hash[:ssi]} as ssi
    ON ssi.fk_source_substance_id = ss.id
    INNER JOIN #{schema_hash[:sm]} as sm
    ON sm.identifier = ssi.identifier
    INNER JOIN #{schema_hash[:gs]} as gs
    ON sm.fk_generic_substance_id = gs.id
    INNER JOIN  #{chemtrack_database}.coa_summaries AS coa
    ON gs.id = coa.gsid
    WHERE (sm.synonym_type = 'CAS-RN' AND ss.id = #{ss_id})
    OR (sm.rank BETWEEN 9 AND 12 AND ss.id = #{ss_id})
    GROUP BY GSID;")
  end


  def set_chemical_list_id
    config = Rails.configuration.database_configuration
    database = config[Rails.env]["database"]
    @chemical_list = ChemicalList.where(list_name: "#{database}_COA_Summary_Chemical_List").order("id DESC").first
  end

end
