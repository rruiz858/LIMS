class Control < ActiveRecord::Base
  belongs_to :order
  belongs_to :source_substance, foreign_key: 'source_substance_id'
  include DsstoxSchema

  def self.order_controls(order_id)
    schema_hash = database_initialization
    Control.select('SQL_CACHE controls.id, controls.identifier, gs.casrn, gs.preferred_name').joins("inner join #{schema_hash[:ss]} as ss
                               on controls.source_substance_id = ss.id
                               inner join #{schema_hash[:sgm]}  as sgm
                               on ss.id = sgm.fk_source_substance_id
                               inner join #{schema_hash[:gs]} as gs
                               on gs.id = sgm.fk_generic_substance_id").where('order_id = ? AND controls = ?', order_id, 1)
  end

  def current_controls(order_id, ss_array)
    set_variables
    Control.select('SQL_CACHE ss.id as ss_id, sgm.fk_generic_substance_id as gsid,
                    ss.id as id, gs.dsstox_substance_id AS dtxsid, gs.casrn as cas,
                    gs.preferred_name as name, 1 AS control,
                    ss.created_at AS created_at, ss.created_by AS created_by')
            .joins("inner join #{@schema_hash[:ss]} as ss on controls.source_substance_id = ss.id")
            .joins("inner join #{@schema_hash[:sgm]}  as sgm  on ss.id = sgm.fk_source_substance_id")
            .joins("inner join #{@schema_hash[:gs]} as gs on gs.id = sgm.fk_generic_substance_id")
            .where('order_id = ? AND controls = ? AND standard_replicate = ? AND source_substance_id IN (?)', order_id, 1, 1, ss_array)
  end

  def add_standard_replicates(order_id , user)
    set_variables
    existing_controls = existing_standards(order_id)
    array_exisiting_ss = []
    if existing_controls.blank?
      ## No Standard Controls were previously added to controls, so we can add all of them to controls
      ss = all_standard_controls
      ssi = source_substance_identifiers
    else
      ## Need to update controls already added that are standard replicates and then add those that were not already in control table for order
      array_exisiting_ss = existing_controls.map { |i| i.id }
      gsid_array = existing_controls.map { |i| i.gsid }
      Control.where(:source_substance_id => array_exisiting_ss).update_all(controls: true, standard_replicate: true, originally_found_replicate: true)
      ss = remaining_standard_controls(gsid_array)
      ssi = source_substance_identifiers
    end
    unless ss.blank?
      new_ss_id = insert_controls(ss, ssi, order_id, user)
      array_non_existing_ss = current_controls(order_id, new_ss_id)
    end
    return array_non_existing_ss, array_exisiting_ss
  end


  def insert_controls(ss, ssi, order_id, user)
    tmp_hash = combine_hash(ss, ssi)
    new_ss_id = []
    tmp_hash.each do |i|
      # Create a new source substance for each new record (every gsid in hash from combine hash)
      source_substance = SourceSubstance.new(fk_chemical_list_id: @control_chemical_list.id, created_by: user , updated_by: user)
      #Create new source substance identifiers for new source substance.
      i[1].each { |j| source_substance.source_substance_identifiers.build(identifier: j['identifier'], identifier_type: j['type'], created_by: user, updated_by: user) }
      # Create source generic substance mapping record
      source_substance.build_source_generic_substance(fk_generic_substance_id: i[0],
                                                      connection_reason: 'standard controls',
                                                      updated_by: user,
                                                      created_by: user,
                                                      curator_validated: true,
                                                      qc_notes: 'This record was added as a standard control for an order in ChemTrack')
      # Create new control record
      source_substance.build_control(order_id: order_id, controls: true, standard_replicate: true, originally_found_replicate: false, identifier: set_order_identifier(order_id))
      source_substance.save
      new_ss_id.push(source_substance.id)
    end
    new_ss_id
  end

  def remove_standard_replicates(order_id)
    set_variables
    existing_controls = existing_standards(order_id)
    existing_array = []
    non_existing_array = []
    existing_controls.each { |i| i.originally_found == 1 ? existing_array.push(i.id) : non_existing_array.push(i.id) }
    #This part does not destroy control records, they just update the control boolean values since control record was previosly a chemical
    existing_array.each do |existing_id|
      control = Control.find_by_source_substance_id(existing_id)
      control.update_attributes(controls: 0, standard_replicate: 0, originally_found_replicate: 0)
      #This part removes control/source susbtance/source_substance_identifier/source_generic_substance_mapping relations for controls that were not previosly in order
    end
    unless non_existing_array.blank?
      source_substances = SourceSubstance.where("id IN (?)", non_existing_array)
      source_substances.destroy_all
    end
    return non_existing_array, existing_array
  end

  def existing_standards(order_id)
    set_variables
    SourceSubstance.select('source_substances.id as id, controls.id as control_id,
                            sgm.fk_generic_substance_id as gsid, source_substances.id as ss_id,
                            gs.dsstox_substance_id AS dtxsid, gs.casrn as cas,
                            gs.preferred_name as name, 1 AS control,
                            source_substances.created_at AS created_at,
                            source_substances.created_by AS created_by,
                            controls.originally_found_replicate AS originally_found,
                            controls.standard_replicate AS standard_replicate')
                   .joins("INNER JOIN  #{@database}.controls as controls on controls.source_substance_id = source_substances.id")
                   .joins("INNER JOIN #{@schema_hash[:sgm]} as sgm on sgm.fk_source_substance_id = source_substances.id")
                   .joins("INNER JOIN #{@schema_hash[:sgm]} as sgm2 on sgm2.fk_generic_substance_id = sgm.fk_generic_substance_id")
                   .joins("INNER JOIN #{@schema_hash[:ss]} as ss2 on ss2.id = sgm2.fk_source_substance_id")
                   .joins("INNER JOIN #{@schema_hash[:gs]} as gs  on sgm2.fk_generic_substance_id = gs.id")
                   .joins("INNER JOIN #{@schema_hash[:database]}.chemical_lists as cl on cl.id = ss2.fk_chemical_list_id "\
                          "where ss2.fk_chemical_list_id = #{@control_chemical_list.id} AND controls.order_id = #{order_id} AND controls.controls = 1")
                  . group('ss_id')
  end

  def self.standard_replicates
    SourceSubstance.find_by_sql(" SELECT
                                  ss.id AS id,
                                  gs.dsstox_substance_id AS dtxsid,
                                  gs.casrn as cas,
                                  gs.preferred_name as name,
                                  gs.id AS gsid,
                                  1 AS control,
                                  ss.created_at AS created_at,
                                  ss.created_by AS created_by
                                  FROM #{@schema_hash[:ss]} AS ss
                                  INNER JOIN #{@schema_hash[:sgm]} AS sgm
                                  ON sgm.fk_source_substance_id = ss.id
                                  INNER JOIN #{@schema_hash[:gs]} AS gs
                                  ON sgm.fk_generic_substance_id = gs.id
                                  WHERE  ss.fk_chemical_list_id = #{list.id}
                                  GROUP BY ss.id")
  end

  # Method is used to find all of the identifiers for source substances in the CT-Standard-Replicates chemical list
  def source_substance_identifiers
    SourceSubstanceIdentifier.select('source_substance_identifiers.id as id, source_substance_identifiers.identifier as identifier,
                                      source_substance_identifiers.identifier_type as type, ss.id as ss_id')
                              .joins("INNER JOIN #{@schema_hash[:ss]} as ss on source_substance_identifiers.fk_source_substance_id = ss.id")
                              .joins("INNER JOIN #{@schema_hash[:sgm]} as sgm on sgm.fk_source_substance_id = ss.id"\
                                     " where ss.fk_chemical_list_id = #{@control_chemical_list.id}"\
                                     " group by source_substance_identifiers.id")

  end

  def all_standard_controls
    SourceSubstance.select('source_substances.id as ss_id,  sgm.fk_generic_substance_id as gsid,
                            source_substances.id as id,
                            gs.dsstox_substance_id AS dtxsid, gs.casrn as cas,
                            gs.preferred_name as name, 1 AS control,
                            source_substances.created_at AS created_at,
                            source_substances.created_by AS created_by')
                    .joins("INNER JOIN #{@schema_hash[:sgm]} as sgm on sgm.fk_source_substance_id = source_substances.id")
                    .joins("INNER JOIN #{@schema_hash[:gs]} as gs  on sgm.fk_generic_substance_id = gs.id"\
                           " where source_substances.fk_chemical_list_id = #{@control_chemical_list.id}"\
                           " group by source_substances.id")

  end

  # Method is used in the add standard replicates method to find control relation ship for controls not already in control table
  def remaining_standard_controls(gsid_array)
    SourceSubstance.select('source_substances.id as ss_id, source_substances.id as id,
                            sgm.fk_generic_substance_id as gsid,
                            gs.dsstox_substance_id AS dtxsid, gs.casrn as cas,
                            gs.preferred_name as name, 1 AS control,
                            source_substances.created_at AS created_at,
                            source_substances.created_by AS created_by')
                    .joins("INNER JOIN #{@schema_hash[:sgm]} as sgm on sgm.fk_source_substance_id = source_substances.id")
                    .joins("INNER JOIN #{@schema_hash[:gs]} as gs  on sgm.fk_generic_substance_id = gs.id")
                    .where("source_substances.fk_chemical_list_id = ? AND sgm.fk_generic_substance_id NOT IN (?)", @control_chemical_list.id, gsid_array)
  end

  # Method is used to give Controls a unique identifier within an Control
  def set_order_identifier(order_id)
    count = Order.joins(:controls).where(id: order_id).count
    count == 0 ? 'CNTRL1' : "CNTRL#{count + 1}"
  end

  # Method returns a hash with the gsid from source substances from CT-Standard-Replicates with arrays of source substances identifiers
  def combine_hash(ss, ssi)
    result_hash = {}
    ss.each do |v1|
      temp_array = Array.new
      ssi.each do |v2|
        if v1.ss_id == v2.ss_id
          result_hash["#{v1.gsid}"] = temp_array.push(v2)
        end
      end
    end
    result_hash
  end

  #Method is used along with Source Substance.available to get a total count of chemicals in an order
  def not_found_in_available(order_id, ss_id)
    set_variables
    SourceSubstance.select('source_substances.id as ss_id, source_substances.id as id,
                            gs.dsstox_substance_id AS dtxsid, gs.casrn as cas,
                            gs.preferred_name as name, 0 as bottle_amount,
                            1 as control, gs.id as gsid,
                            controls.standard_replicate as replicate')
                    .joins("INNER JOIN  #{@database}.controls as controls on controls.source_substance_id = source_substances.id")
                    .joins("INNER JOIN #{@schema_hash[:sgm]} as sgm on sgm.fk_source_substance_id = source_substances.id")
                    .joins("INNER JOIN #{@schema_hash[:gs]} as gs  on sgm.fk_generic_substance_id = gs.id")
                    .where("controls.standard_replicate = ? AND controls.order_id = ? AND controls.controls = ? AND source_substances.id NOT IN (?)", 1, order_id, 1, ss_id)
  end

  private

  def set_variables
    @schema_hash = database_initialization
    @control_chemical_list = ChemicalList.new.control_chemical_list
    @config = Rails.configuration.database_configuration
    @database = @config[Rails.env]["database"]
  end


end
