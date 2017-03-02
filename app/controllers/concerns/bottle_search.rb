module BottleSearch
  extend ActiveSupport::Concern
  require 'erb'
  include ERB::Util
  include DsstoxSchema
  include UsersHelper



  private
  def search_bottle(term)
    @resolver_hash = Hash.new(0)
    if test_database_connection
      resolver_service(term)
      if @resolver_hash[:gsid]
        query = find_bottles(@resolver_hash[:gsid])
        if query.empty?
          return nil, -1, @resolver_hash  #bottles not found even though info is in Dsstox
        else
          bottles = populate_resolver_hash(query)
          return bottles, 1, @resolver_hash #query found bottles
        end
      else
        return nil, -2 #nothing was found in Dsstox/resolver services is down
      end
    else
      return nil, 0 #connection to Dsstox is down
    end
  end

  def test_database_connection
    begin
      GenericSubstance.first
    rescue
      return false
    end
  end


  def resolver_service(term)
    url_term = url_encode(term)
    url = URI.parse("http://actorws.epa.gov/actorws/chemIdentifier/v01/resolve.json?identifier=#{url_term}")
    req = Net::HTTP::Get.new(url.to_s)
    begin
      res = Net::HTTP.start(url.host, url.port) do |http|
        http.request(req)
      end
    rescue => error
     Rails.logger.info "\n" + "############################" + "\n"
                            "#{error.class}:#{error.message}" +
                            "\n" + "########################" +"\n"
      res = ''
    end
      if  res.is_a? Net::HTTPSuccess
        tmp_result = JSON.parse(res.body)
        if !tmp_result['DataRow']['synGsid'].nil?
          @resolver_hash[:search_term] = tmp_result['DataRow']['synType']
          @resolver_hash[:gsid] = tmp_result['DataRow']['synGsid']
        else
          other_searches(term)
          Rails.logger.info "Term not found" unless @resolver_hash[:gsid]
        end
      else
        other_searches(term)
        Rails.logger.info "Term not found/Actor could be down" unless @resolver_hash[:gsid]
      end
  end

  def other_searches(term)
    if find_by_barcode(term) || ((chemadmin? || admin?) && find_by_sample_id(term))  #only chemadmins and admins can find by epa_sample_id(blinded sample ids)
      @resolver_hash[:bottle_id] = @search.id
      @single_result = true
      @resolver_hash[:search_term] = term
      @resolver_hash[:gsid] = @search.gsid.to_i
    else
      @resolver_hash[:gsid] = false
    end
  end

  def find_by_barcode(term)
    @search = Bottle.joins(:coa_summary).select("bottles.id as id,coa_summaries.gsid as gsid").where('stripped_barcode = ? OR barcode = ? OR barcode_parent = ?',term, term, term).first
    gsid_exsits?(@search)
  end

  def find_by_sample_id(term)
    @search = plate_detail_search(term) || vial_detail_search(term)
    gsid_exsits?(@search)
  end

  def plate_detail_search(term)
    Bottle.joins(:plate_details).joins(:coa_summary).select('bottles.id as id, coa_summaries.gsid as gsid').where("plate_details.blinded_sample_id = ?", term).first
  end

  def vial_detail_search(term)
    Bottle.joins(:vial_details).joins(:coa_summary).select('bottles.id as id, coa_summaries.gsid as gsid').where("vial_details.blinded_sample_id = ?", term).first
  end

  def gsid_exsits?(search)
    if search.nil?
      false
    elsif search.gsid.nil?
      false
    else
      true
    end
  end

  def find_bottles(gsid)
    dsstox_hash = database_initialization
    config = Rails.configuration.database_configuration
    chemtrack = config[Rails.env]["database"]
    Bottle.find_by_sql(["SELECT b.id as bottle_id, b.stripped_barcode AS stripped_barcode,gs.id AS gsid, gs.casrn AS casrn,
                        gs.preferred_name AS preferred_name, gs.dsstox_substance_id AS dsstox_substance_id,
                        b.qty_available_mg_ul AS qty_available_mg_ul, b.concentration_mm AS concentration_mm,
                        b.units AS units, b.vendor AS vendor, b.coa_summary_id AS COA
                        FROM #{chemtrack}.coa_summaries AS coa
                        INNER JOIN #{dsstox_hash[:gs]} AS gs
                        ON gs.id = coa.gsid
                        INNER JOIN #{chemtrack}.bottles AS b
                        ON coa.id = b.coa_summary_id
                        WHERE (gs.id IN (?));", gsid])

  end

  def populate_resolver_hash(query)
    @resolver_hash[:casrn] = query.first.try(:casrn)
    @resolver_hash[:dsstox_substance_id]= query.first.try(:dsstox_substance_id)
    @resolver_hash[:name] = query.first.try(:preferred_name)
    #if param is either a barcode or a blinded sample, only one result will show since that's what the product owner wants..
    @single_result ? query.select {|i| i.attributes['bottle_id'].to_i == @resolver_hash[:bottle_id].to_i} : query
  end

  def bottle_coa_summary_join(gsid_array)  #used for export of bottles in multiple chemical search
    Bottle.select("gsid, qty_available_mg_ul, stripped_barcode, units, concentration_mm").joins(:coa_summary).where(coa_summaries: {gsid: gsid_array})
  end

end