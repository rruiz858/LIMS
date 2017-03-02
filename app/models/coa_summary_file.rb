class CoaSummaryFile < ActiveRecord::Base
  include OpenExcel
  include DsstoxSchema
  mount_uploader :file_url, CoaSummaryFileUploader
  belongs_to :user
  has_one :delayed_job, :as => :job
  has_one :file_error, as: :errorable, dependent: :destroy
  validates :file_url, presence: {message: "Must select a file"}
  validate :validate_content_type, :validate_excel


  def validate_content_type
    unless file_url.path.blank?
      mime_types = ["text/csv", "application/csv", "text/comma-separated-values", "application/excel", "application/vnd.ms-excel", "application/msexcel", "application/x-msexcel", "application/x-ms-excel", "application/x-excel", "application/x-dos_ms_excel", "application/xls", "application/x-xls", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"]
      unless mime_types.include? file_url.content_type
        errors.add(:file_url, ' * Invalid MIME type')
      end
    end
  end

  def validate_excel
    unless file_url.path.blank?
      accepted_formats = [".xls", ".xlsx", ".csv"]
      if accepted_formats.include? File.extname(file_url.path)
        sheet = open_spreadsheet(file_url.path)
        header = sheet.row(1).map(&:downcase)
        num_of_columns = sheet.last_column
        if num_of_columns < 12
          errors.add(:file_url, ' * Not enough columns in COA Summary File')
        end
        unless header.include?("bottle barcode")
          errors.add(:file_url, ' * Bottle Barcode Header is missing')
        end
        unless header.include?("coa_product_no")
          errors.add(:file_url, ' * COA_Product_No Header is missing')
        end
        unless header.include?("coa_lot number")
          errors.add(:file_url, ' * COA_Lot Number Header is missing')
        end
        unless header.include?("coa_chemicalname")
          errors.add(:file_url, ' * COA_ChemicalName Header is missing')
        end
        unless header.include?("coa_molecularweight")
          errors.add(:file_url, ' * COA_MolecularWeight Header is missing')
        end
        unless header.include?("coa_density")
          errors.add(:file_url, ' * COA_Density" Header is missing')
        end
        unless header.include?("coa_purity_(%)")
          errors.add(:file_url, ' * COA_Purity_(%) Header is missing')
        end
        unless header.include?("coa_methods")
          errors.add(:file_url, ' * COA_Methods Header is missing')
        end
        unless header.include?("coa test date")
          errors.add(:file_url, ' * COA Test Date Header is missing')
        end
        unless header.include?("coa expiration date")
          errors.add(:file_url, ' * CoA Expiration Date Header is missing')
        end
        unless header.include?("msds_cautions")
          errors.add(:file_url, ' * CONCENTRATION_mM Header is missing')
        end
        self.coa_summary_count= sheet.count
      else
        errors.add(:file_url, ' * Wrong extension')
      end
    end
  end


  def self.create_dsstox_mapping(coa_summary_ids, user)
    schema_hash = database_initialization
    config = Rails.configuration.database_configuration
    database = config[Rails.env]["database"]
    chemical_list = ChemicalList.where(list_name: "#{database}_COA_Summary_Chemical_List").order("id DESC").first
    connection = ActiveRecord::Base.connection
    connection.execute("INSERT INTO #{schema_hash[:ss]}(fk_chemical_list_id, dsstox_record_id, external_id, created_by, updated_by, created_at, updated_at)
    SELECT #{chemical_list.id},
    'test',
    coa.id,
    '#{user.username}', '#{user.username}', coa.created_at, coa.updated_at
    FROM coa_summaries AS coa
    INNER JOIN bottles AS b
    ON b.stripped_barcode = coa.bottle_barcode
    WHERE coa.id IN (#{coa_summary_ids.join(', ')});")

    ##Insert into source_susbtance_identifiers for CASRN type
    connection.execute("INSERT INTO #{schema_hash[:ssi]} (fk_source_substance_id, identifier, identifier_type, created_by, updated_by, created_at, updated_at)
    SELECT ss.id,
    (CASE WHEN coa.coa_casrn IS NOT NULL THEN coa.coa_casrn ELSE b.cas END) AS identifier,
    'CASRN',
    '#{user.username}',
    '#{user.username}',
    coa.created_at,
    coa.updated_at
    FROM #{schema_hash[:ss]} AS ss
    INNER JOIN coa_summaries AS coa
    ON coa.id = ss.external_id
    INNER JOIN bottles AS b
    ON b.stripped_barcode = coa.bottle_barcode
    WHERE
    ss.fk_chemical_list_id = #{chemical_list.id}
    AND ss.id NOT IN (SELECT  DISTINCT(ssi.fk_source_substance_id) FROM #{schema_hash[:ssi]} AS ssi WHERE ssi.identifier_type = 'CASRN');")

    ##Insert into source_substance_identifiers for NAME type
    connection.execute("INSERT INTO #{schema_hash[:ssi]} (fk_source_substance_id, identifier, identifier_type, created_by, updated_by, created_at, updated_at)
    SELECT ss.id,
    (CASE WHEN coa.coa_chemical_name IS NOT NULL THEN coa.coa_chemical_name ELSE b.compound_name END) AS identifier,
    'NAME',
    '#{user.username}',
    '#{user.username}',
    coa.created_at,
    coa.updated_at
    FROM #{schema_hash[:ss]} AS ss
    INNER JOIN coa_summaries AS coa
    ON coa.id = ss.external_id
    INNER JOIN bottles AS b
    ON b.stripped_barcode = coa.bottle_barcode
    WHERE
    ss.fk_chemical_list_id = #{chemical_list.id}
    AND ss.id NOT IN (SELECT  DISTINCT(ssi.fk_source_substance_id) FROM #{schema_hash[:ssi]} AS ssi WHERE ssi.identifier_type = 'NAME');")

    ##Insert into source_susbtance_identifiers for BOTTLE type
    connection.execute("INSERT INTO #{schema_hash[:ssi]} (fk_source_substance_id, identifier, identifier_type, created_by, updated_by, created_at, updated_at)
    SELECT ss.id,
    coa.bottle_barcode,
    'BOTTLE',
    '#{user.username}',
    '#{user.username}',
    coa.created_at,
    coa.updated_at
    FROM #{schema_hash[:ss]} AS ss
    INNER JOIN coa_summaries AS coa
    ON coa.id = ss.external_id
    AND
    ss.fk_chemical_list_id = #{chemical_list.id}
    AND ss.id NOT IN (SELECT  DISTINCT(ssi.fk_source_substance_id) FROM #{schema_hash[:ssi]} AS ssi WHERE ssi.identifier_type = 'BOTTLE');")

    ##Update coa summarie's source substance id field
    connection.execute("UPDATE coa_summaries AS coa
     INNER JOIN #{schema_hash[:ss]} AS ss
     ON ss.external_id = coa.id
     SET coa.source_substance_id = ss.id
     WHERE coa.source_substance_id IS NULL
     AND coa.chemical_list_id = ss.fk_chemical_list_id")

    #This method maps orphan bottles to a coa summary if conditions are met
    CoaSummaryFile.coa_summary_bottle_mapping
  end


  def self.coa_summary_bottle_mapping
    sql = ['UPDATE bottles AS b
    INNER JOIN coa_summaries AS cs
    ON b.stripped_barcode = cs.bottle_barcode
    set b.coa_summary_id = cs.id
    WHERE b.coa_summary_id IS NULL;',
           'UPDATE bottles AS b_child
    INNER JOIN bottles AS b_parent
    ON b_parent.barcode = b_child.barcode_parent
    SET b_child.coa_summary_id = b_parent.coa_summary_id
    WHERE b_parent.coa_summary_id IS NOT NULL
    AND b_child.coa_summary_id IS NULL;',
           'UPDATE bottles AS b_child
    INNER JOIN bottles AS b_parent
    ON b_parent.lot_number = b_child.lot_number
    SET b_child.coa_summary_id = b_parent.coa_summary_id
    WHERE b_child.vendor = b_parent.vendor
    AND b_child.cpd = b_parent.cpd
    AND b_child.coa_summary_id IS NULL
    AND b_child.lot_number IS NOT NULL
    AND b_parent.lot_number IS NOT NULL
    AND b_parent.coa_summary_id IS NOT NULL;',
           'UPDATE bottles AS b_child
    INNER JOIN bottles AS b_parent
    ON b_parent.cpd = b_child.cpd
    SET b_child.coa_summary_id = b_parent.coa_summary_id
    WHERE b_child.coa_summary_id IS NULL
    AND b_parent.coa_summary_id IS NOT NULL
    AND b_child.vendor = b_parent.vendor
    AND b_child.sam = b_parent.sam
    AND b_child.lot_number IS NULL;']
    sql.each do |statement|
      ActiveRecord::Base.connection.execute(statement)
    end
  end


end
