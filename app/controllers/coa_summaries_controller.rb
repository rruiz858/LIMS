class CoaSummariesController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  load_and_authorize_resource
  before_action :set_coa_summary, only: [:show, :override_show, :override_gsid]
  include MatchedKinds

  # GET /coa_summaries
  # GET /coa_summaries.json
  def index
    @coa_summary_files = CoaSummaryFile.all
    @uncurated = CoaSummary.uncurated
    @curated = CoaSummary.curated
    respond_to do |format|
      format.html
      format.json { render json: CuratedCoaDatatable.new(view_context) }
    end
  end

  # GET /coa_summaries/1
  # GET /coa_summaries/1.json
  def show
    @bottle =  @coa_summary.direct_bottle_match
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def table_types
    match_type = params[:kind].tr('-', '_')
    @results_query = send(match_type)
    html_string = ''
    if match_type == 'no_hits'
      @results_query.each do |i|
        coa_summary =  SourceSubstance.find("#{i.attributes["id"]}").coa_summary
        html_string +=
            '<tr>' +
                '<td>' + "#{i.attributes["BARCODE"]}" + '</td>' +
                '<td>' + "#{i.attributes["SOURCENAME"]}" + '</td>' +
                '<td>' + "#{i.attributes["SOURCECASRN"]}" + '</td>' +
                '<td>' + "#{i.attributes["preferred_name"]}" + '</td>' +
                '<td>' + "#{i.attributes["CASRN"]}" + '</td>' +
                '<td class="gsid-coa">' + "#{i.attributes["GSID"]}" + '</td>' +
                '<td>' +
                "<div style='text-align: center' >" +
                "<a href= #{override_show_coa_summary_path(coa_summary)} data-remote='true'>" +
                '<button class="btn btn-default btn-xs"> Define'+
                '</button></a>' +
                '</div>' +
                '</td>' +
                '<td>' + "N/A" + '</td>' +
                '<td>' + "N/A" + '</td>' +
            '</tr>'
      end
    elsif match_type == 'name_other'
      @results_query.each do |i|
        coa_summary =  SourceSubstance.find("#{i.attributes["id"]}").coa_summary
        html_string +=
            '<tr id = "' + "#{i.attributes["id"]}" + '">' +
                '<td>' + "#{i.attributes["BARCODE"]}" + '</td>' +
                '<td'+ " id='nameTest-#{i.attributes['SOURCENAME']}'" + '>' + "#{i.attributes["SOURCENAME"]}" + '</td>' +
                '<td>' + "#{i.attributes["SOURCECASRN"]}" + '</td>' +
                '<td>' + "#{i.attributes["preferred_name"]}" + '</td>' +
                '<td>' + "#{i.attributes["CASRN"]}" + '</td>' +
                '<td class>' + "#{i.attributes["GSID"]}" + '</td>' +
                '<td>' +
                "<div style='text-align: center' >" +
                "<a href= #{override_show_coa_summary_path(coa_summary)}?param1='name-other' data-remote='true'>" +
                '<button class="btn btn-default btn-xs"> More Options'+
                '</button></a>' +
                '</div>' +
                '</td>' +
                '<td>' + "#{i.attributes["COA_NAME_NULL"]}" + '</td>' +
                '<td>' + "#{i.attributes["COA_CASRN_NULL"]}" + '</td>' +
                '</tr>'
      end
    else
      @results_query.each do |i|
        coa_summary =  SourceSubstance.find("#{i.attributes["id"]}").coa_summary
        html_string +=
            '<tr id ="' + "#{i.attributes["id"]}TrId" + '">' +
                '<td>' + "#{i.attributes["BARCODE"]}" + '</td>' +
                '<td>' + "#{i.attributes["SOURCENAME"]}" + '</td>' +
                '<td>' + "#{i.attributes["SOURCECASRN"]}" + '</td>' +
                '<td>' + "#{i.attributes["preferred_name"]}" + '</td>' +
                '<td>' + "#{i.attributes["CASRN"]}" + '</td>' +
                '<td class="gsid-coa">' + "#{i.attributes["GSID"]}" + '</td>' +
                '<td>' +
                "<div style='text-align: center' >" +
                '<button class="curate-coa btn btn-xs btn-success"' + 'id='+ "#{i.attributes["id"]}" + '>Validate
                 <span class="glyphicon glyphicon-ok"></span></button>' + '&nbsp;' +
                "<a href= #{override_show_coa_summary_path(coa_summary)} data-remote='true'>" +
                '<button class="btn btn-default btn-xs"> Define'+
                '</button></a>' +
                '</div>' +
                '</td>' +
                '<td>' + "#{i.attributes["COA_NAME_NULL"]}" + '</td>' +
                '<td>' + "#{i.attributes["COA_CASRN_NULL"]}" + '</td>' +
            '</tr>'
      end
    end
    respond_to do |format|
      result = Hash.new(0)
      result[:html] = html_string.to_s
      format.json { render json: result }
    end
  end

  def curate_coas
    @errors = ''
    curate(params[:gsId], params[:ssId], 'Chemtrack Validated')
    respond_to do |format|
      format.json {render json: @mapping }
    end
  end

  def uncurated_counts
    matched_hash = {casrn_name: casrn_name.count, name_other: name_other.count, casrn: casrn.count, name: name.count, no_hits: no_hits.count }
    respond_to do |format|
      format.json {render json: matched_hash }
    end
  end

  def total_uncurated_count
    count_hash = {uncurated_count: CoaSummary.uncurated.count}
    respond_to do |format|
      format.json {render json: count_hash }
    end
  end


  def update_control
    control = Control.find_by_source_substance_id(params[:id])
    control.update_attributes(controls: params[:state])
    respond_to do |format|
      format.json {render json: control }
    end
  end

  def override_show
    if params[:param1] == "'name-other'"
      @name_other= true
      @potential_matches = coa_matches_query(@coa_summary.source_substance_id)
    end
    respond_to do |format|
      format.js { render 'coa_summaries/override_show'}
    end
  end

  def override_gsid
    gsid =  override_gsid_params[:gsid]
    found_gsid = gsid_valid?(gsid)  #populates the @errors object
    curate(found_gsid, @coa_summary.source_substance_id, params[:comment]) if @errors.nil?
    respond_to do |format|
      format.js { render 'coa_summaries/override_gsid' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_coa_summary
      @coa_summary = CoaSummary.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def coa_summary_params
      params.require(:coa_summary).permit(:bottle_barcode, :coa_table_entry, :coa, :msds, :inventory_source, :coa_product_no, :coa_lot_number, :coa_chemical_name, :coa_casrn, :coa_molecular_weight, :coa_density, :coa_purity_percentage, :coa_methods, :coa_test_date, :coa_expiration_date, :msds_cautions, :coa_review_notes, :reviewer_initials, :commercial_source, :gsid )
    end

    def dsstox_params
      params.require(:coa_summary).permit(:gsid)
    end

    def override_gsid_params
      params.permit(:comment, :gsid)
    end

  def gsid_valid?(gsid)
    found_gsid = GenericSubstance.gsid_found(gsid)
    !found_gsid ? @errors = "No GSID was matching '#{gsid}' was found" : found_gsid
  end

  def curate(gsid, ssid, comment)
    begin
      @errors ||= ''
      ActiveRecord::Base.transaction do
        @user = @current_user.username
        @mapping = SourceGenericSubstance.find_by_fk_source_substance_id(ssid)
        coa_summary = SourceSubstance.find(ssid).coa_summary
        SourceGenericSubstance.transaction do
        @mapping.update_attributes(fk_generic_substance_id: gsid, curator_validated: 1, updated_by: @user, qc_notes: comment)
          CoaSummary.transaction do
            coa_summary.update_attributes(gsid: @mapping.fk_generic_substance_id)
          end
        end
      end
    rescue => e
      @errors << "\n" + e.to_s
      Rails.logger.error @errors
    end
  end

end
