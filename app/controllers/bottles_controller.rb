class BottlesController < ApplicationController
  require 'json'
  include TestEnvironment
  load_and_authorize_resource
  before_filter :authenticate_user!, except: [:single_results, :multiple_results, :show, :show_bottle_results, :export_chemicals, :open_bottle_file, :index]
  before_action :set_bottle, only: [:show, :edit, :update, :destroy]
  before_action :set_coa_chemical_list, only: [:create]
  before_action :set_bottle_objects, only: [:index, :update, :edit_external_bottle]
  include BottleSearch
  include DsstoxSchema
  include SourceSubstanceGenericMapping
  include MultipleSearch


  def index
    @bottle = Bottle.new
    if can? :update, @bottle
      respond_to do |format|
        format.html
        format.json { render json: BottlesDatatable.new(view_context)}
      end
    else
      respond_to do |format|
        format.html
        format.json { render json: BottlesDatatableNotSignedIn.new(view_context) }
      end
    end
  end

  def single_results
    begin
      @search_term = params[:search].strip
      @results = search_bottle(@search_term)
      @bottles = @results[0]
      @type = @results[1]
      @resolver_params = @results[2]
    rescue
      @type = -3
      @search_term = params[:search]
    end
    respond_to do |format|
      format.html
    end
  end


  def multiple_results
    @query_results = Hash.new(0)
    @formatted_params = Hash.new(0)
    if params[:find_results]
      search_terms= params[:chemical_search].split(/\r\n/).collect{|x| x.strip || x}
      @formatted_params = format_search_params(params)
      @result_hash = multi_chemical_search(search_terms, @formatted_params)
      respond_to do |format|
        format.html
        format.js { render :partial => 'bottles/multiple_results_partials/results' }
      end
    end
  end


  # GET /bottles/1
  # GET /bottles/1.json
  def show
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  # GET /bottles/new
  def new
    @bottle = Bottle.new
  end

  def show_bottle_results
    user_params =  params[:params]
    query_values(user_params)
    respond_to do |format|
      @resolver_hash = Hash.new(0)
      query = advanced_bottle_search(user_params, params[:gsid])
      temp_string = '<table class= "table table-condensed">
                     <tr><th>Barcode</th>
                         <th>Supplier</th>
                         <th>QTY</th>
                         <th>Units</th>
                         <th>Concentration (mM)</th>
                     </tr>'
      if query.blank?
        temp_string +=
            '<tr>' +
                '<td>' + '-' + '</td>' +
                '<td>' + '-' + '</td>' +
                '<td>' + '-' '</td>' +
                '<td>' + '-' '</td>' +
                '<td>' + '-' '</td>' +
                '<td>' + '-' '</td>' +
                '</tr>'
      else
        bottles = populate_resolver_hash(query)
        bottles.each do |i|
          temp_string +=
              '<tr>' +
                  "<td id=barcode-#{i.attributes['stripped_barcode']}>" + "#{i.attributes['stripped_barcode']}" + '</td>' +
                  '<td>' + "#{i.attributes['vendor']}" + '</td>' +
                  '<td>' + "#{i.attributes['qty_available_mg_ul']}" '</td>' +
                  '<td>' + "#{i.attributes['units']}" '</td>' +
                  '<td>' + "#{i.attributes['concentration_mm']}" + '</td>' +
                  '</tr>'
        end

      end
      temp_string += '</table>'
      result = Hash.new(0)
      result[:html] = temp_string.to_s
      format.json { render json: result }
    end
  end

  # POST /bottles
  # POST /bottles.json
  def create
    coa_summary_id = Array.new
    @last_id = Bottle.last.id
    @bottle = Bottle.new(external_bottle_params)
    @bottle.stripped_barcode = create_external_id
    @bottle.barcode = @bottle.stripped_barcode
    @bottle.external_bottle = true
    if @bottle.save
      @coa_summary = CoaSummary.create(bottle_barcode: @bottle.stripped_barcode, coa_chemical_name: @bottle.compound_name, coa_casrn: @bottle.cas, chemical_list_id: @chemical_list.id)
      @bottle.update_attributes(coa_summary_id: @coa_summary.id)
      coa_summary_mapping(coa_summary_id.push(@coa_summary.id)) #this method creates source substance, source substance identifiers, and source generic mapping
      redirect_to bottles_path
      flash[:success] = "External Bottle #{@bottle.stripped_barcode}, & COA Summary was added, please curate COA Summary"
    else
      redirect_to bottles_path
      error_str = ""
      @bottle.errors.full_messages.each do | message|
        error_str += message + "\n"
      end
      flash[:error] = "Validation Error #{ "\n" + error_str}"
    end
  end

  # PATCH/PUT /bottles/1
  # PATCH/PUT /bottles/1.json
  def update
    respond_to do |format|
      @bottle.updated_by = current_user.username
      unless @bottle.update(bottle_params)
        @errors = ""
        @bottle.errors.full_messages.each do |message|
          @errors += message + "\n"
        end
      end
      format.html
      format.js { render 'bottles/update' }
      format.json { render json: BottlesDatatable.new(view_context) }
    end
  end

  def edit_external_bottle
   @external_bottle = Bottle.find(params[:id])
    if params[:update_external]
      respond_to do |format|
        @external_bottle.updated_by = current_user.username
        unless @external_bottle.update(external_bottle_params)
          @errors = ""
          @external_bottle.errors.full_messages.each do |message|
            @errors += message + "\n"
          end
        end
        format.html
        format.js { render 'bottles/update_external' }
        format.json { render json: BottlesDatatable.new(view_context) }
      end
    end
  end

  # DELETE /bottles/1
  # DELETE /bottles/1.json
  def destroy
    @bottle.destroy
    respond_to do |format|
      format.html { redirect_to bottles_url, notice: 'Bottle was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def export_chemicals
    temp_string = params[:data].gsub('=>', ':').gsub('nil', 'null')
    user_params =  params[:params]
    decoded_string = ActiveSupport::JSON.decode(temp_string)
    decoded_string.is_a?(String) ?  sheet_one_results = JSON.parse(decoded_string) : sheet_one_results = decoded_string
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => 'Chemicals'
    sheet2 = book.create_worksheet :name => 'All Bottles'
    sheet1.row(0).concat %w{
    query
    found_by
    gsid
    preferred_name
    casrn
    }
    sheet_one_results.each_with_index do |bottle, i|
      sheet1.row(i+1).replace [bottle["searched_term"],
                               bottle["kind"],
                               bottle["gsid"],
                               bottle["preferred_name"],
                               bottle["casrn"]]
    end
    gsid_array = sheet_one_results.map{|bottle| bottle['gsid']}.compact
    gsid_string = gsid_array
    query_values(user_params)
    query = advanced_bottle_search(user_params, gsid_string).as_json
    sheet_two_results = query.map{|i| i.merge(sheet_one_results.find{|h| h["gsid"] == i["gsid"] })}
    sheet2.row(0).concat %w{
    query
    found_by
    gsid
    preferred_name
    casrn
    barcode
    quantity
    units
    concentration_mM
    }
    sheet_two_results.each_with_index do |bottle, i|
      sheet2.row(i+1).replace [bottle["searched_term"],
                               bottle["kind"],
                               bottle["gsid"],
                               bottle["preferred_name"],
                               bottle["casrn"],
                               bottle["stripped_barcode"],
                               bottle["qty_available_mg_ul"],
                               bottle["units"],
                               bottle["concentration_mm"]]
    end
    path = "public/chemical_export.xls"
    book.write path
    respond_to do |format|
      format.json {render :json => path.to_json }
    end
  end
  def open_bottle_file
    path = params[:path]
    basename = File.basename(path)
    send_file path, :content_type => "application/vnd.ms-excel" ,disposition: "inline", filename: basename
  end
  private
  # Use callbacks to share common setup or constraints between actions.

  def format_search_params(params)
    if params[:min_conc].present? && params[:max_conc].present? && params[:amount].present? #solution sample
      {solution: true, min_conc: params[:min_conc], max_conc: params[:max_conc], amount: params[:amount], units: "('ul')", unit: 'ul',type: 'solution'}
    elsif params[:min_conc].blank? && params[:max_conc].blank? && params[:amount].present? #neat sample
      {neat: true, min_conc: '0', max_conc: '0', amount: params[:amount], units: "('mg')", unit: 'mg',type: 'neat'}
    else #search all
      {all: true}
    end
  end

  def coa_summary_mapping(coa_summary_id)
    @user = current_user
    schema = database_initialization
    CoaSummaryFile.create_dsstox_mapping(coa_summary_id, @user)
    @source_substances = SourceSubstance.find_by_sql("SELECT ss.id FROM #{schema[:ss]} AS ss WHERE ss.id NOT IN( SELECT sgm.fk_source_substance_id FROM
                                                      #{schema[:sgm]} as sgm) AND ss.fk_chemical_list_id = #{@chemical_list.id} ;")
    source_generic_mapping(@source_substances, @user.username)
  end

  def set_bottle
    @bottle = Bottle.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def bottle_params
    params.require(:bottle).permit( :can_plate, :comment)
  end
  def external_bottle_params
    params.require(:bottle).permit( :status, :cid, :vendor, :compound_name, :cas, :qty_available_mg_ul, :concentration_mm, :sam, :cpd, :lot_number, :can_plate, :units, :comment, :form,
    :qty_available_umols, :structure_real_amw, :vendor_part_number, :po_number)
  end

  def set_coa_chemical_list
    config = Rails.configuration.database_configuration
    database = config[Rails.env]["database"]
    @chemical_list = ChemicalList.where(list_name: "#{database}_COA_Summary_Chemical_List").order("id DESC").first
  end

  def set_bottle_objects
    @bottles = Bottle.where("qty_available_mg_ul >0").where("coa_summary_id IS NOT NULL")
    @external_bottles = Bottle.external
    @bottles_no_coa = Bottle.where("qty_available_mg >0 || qty_available_ul >0").where("coa_summary_id IS NULL")
  end

  def create_external_id #this makes sure bottle barcode of Bottle is generated
    @query = Bottle.where("stripped_barcode LIKE ?", "EX00%").order("id DESC").first
    if @query.blank?
      external_id ="EX000001"
    else
      query_string = @query.stripped_barcode.gsub(/EX/, '')
      query_integer = query_string.to_i + 1
      external_id ="EX0000"+"#{query_integer}"
    end
    return external_id
  end

end
