class SourceSubstancesController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_source_substance, only: [:destroy, :edit, :update, :show_gsids, :update_gsid, :destroy]
  before_action :order_owner, only: [:destroy]

  def edit
    @chemical_list = @source_substance.chemical_list
    @control = @source_substance.control
  end

  # POST /
  # POST /
  def create
    @chemical_list = ChemicalList.find(params[:fk_chemical_list_id])
    @user = current_user.username
    @order = Order.find(@chemical_list.order_chemical_list.order_id)
    @order_amount = @order.amount
    if params[:add_list]
      @added_chemical_list = ChemicalList.find(params[:new_chemical_list_id])
      SourceSubstance.list_insert(@added_chemical_list, @chemical_list, @user, @order)
      update_order_status(@order, OrderStatus.find_by_name('adding_chemicals'))
    elsif params[:add_text]
      list= params[:chemical].split(/\r\n/)
      header = list[0]
      keys_array = []
      rows_array = []
      hash_array = []
      keys = header.split(",").map(&:strip)
      keys.each do |key|
        keys_array.push(key)
      end
      list[1..-1].each do |a|
        texts = a.split(",").map(&:strip)
        texts.each do |text|
          rows_array.push(text)
        end
        correlated = Hash[keys_array.zip rows_array]
        @source_substance = @chemical_list.source_substances.build(fk_chemical_list_id: @chemical_list.id,
                                                                   dsstox_record_id: "TEST",
                                                                   created_by: @user,
                                                                   updated_by: @user)
        @source_substance.save
        correlated.each do |key, value|
          unless value.blank?
          @identifier =  @source_substance.source_substance_identifiers.build(fk_source_substance_id: @source_substance.id,
                                                                 identifier: value,
                                                                 identifier_type: key.upcase,
                                                                 created_by: @user,
                                                                 updated_by: @user)
          @identifier.save
          end
        end
        SourceSubstance.dsstox_mapping(@source_substance)
        hash_array.push(correlated)
        rows_array = Array.new
        update_order_status(@order, OrderStatus.find_by_name('adding_chemicals'))
      end
    end
    @order_concentration = @order.order_concentration.concentration
    @available = SourceSubstance.available_and_controls(@chemical_list.id,@order_amount, @order_concentration, @order.id)
    @not_available = SourceSubstance.not_available(@chemical_list.id, @order_amount, @order_concentration)
    @duplicates = SourceSubstance.duplicates(@chemical_list.id)
    @no_hits = SourceSubstance.no_hits(@chemical_list.id)
    @results_hash = {"available" => @available, "not_available" => @not_available, "duplicates" => @duplicates, "no_hits" => @no_hits}
    respond_to do |format|
      format.json { render json: @results_hash}
      format.js
    end
  end


  def update
    @chemical_list = @source_substance.chemical_list
    respond_to do |format|
      if @source_substance.update_attributes(source_substance_params)
        format.json { render json: @chemical_list }
        format.js
      end
    end
  end

  def show_gsids
    @order = Order.find(@chemical_list.order_chemical_list.order_id)
    if SourceSubstance.multiple_gsid(@source_substance)
      results_hash = SourceSubstance.get_identifiers(@source_substance)
      @gsids = SourceSubstance.get_gsid(results_hash["CASRN"], results_hash["DTXSID"], results_hash["BOTTLE_ID"], results_hash["SAMPLE_ID"])
      results = Array.new
      @gsids.each do |gsid|
        temp_hash = {}
        @generic_substance = GenericSubstance.find(gsid)
        temp_hash = {gsid: gsid, casrn: @generic_substance.casrn, preferred_name: @generic_substance.preferred_name, substance_type: @generic_substance.substance_type}
        results.push(temp_hash)
      end
      @gsid_array = results
    else
      redirect_to order_chemical_list_path(@order,@chemical_list)
      flash[:error] = "This substance does not have multiple GSIDs"
    end
  end

  def update_gsid
    if !(params[:change_gsid].blank?)
      @user = current_user.username
      @source_generic_substance = @source_substance.source_generic_substance
      @source_generic_substance.update_attributes(fk_generic_substance_id: params[:gsid], updated_by: @user, updated_at: Time.now)
      redirect_to :back
      flash[:success] = "GSID was successfully updated"
    else
      redirect_to :back
      flash[:error] = "Must select a GSID"
    end
  end

  # DELETE /
  # DELETE /
  def destroy
    @source_substance.destroy
    respond_to do |format|
      format.html { redirect_to :back  }
      format.json { head :no_content }
      flash[:success] = "Record was successfully destroyed."
  end
end

  def show_identifiers
    respond_to do |format|
      query = SourceSubstanceIdentifier.where(fk_source_substance_id: params[:id])
      temp_string = '<table class= "table table-condensed table-bordered"><tr><th>Source Substance Identifier ID</th><th>Identifier</th><th>Identifier Type</th></tr>'
      query.each do |i|
        temp_string +=
            '<tr>' +
                '<td>' + "#{i.id}" + '</td>' +
                '<td>' + "#{i.identifier}" + '</td>' +
                '<td>' + "#{i.identifier_type}" '</td>' +
                '</tr>'
      end
      temp_string += '</table>'
      result = Hash.new(0)
      result[:html] = temp_string.to_s
      format.json { render json: result }
    end
  end

  def update_control
    @order = Order.find(params[:order])
    control = Control.find_or_initialize_by(source_substance_id: params[:id])
    control.assign_attributes(controls: params[:state], order_id: @order.id)
    control.identifier = Control.new.set_order_identifier(@order.id) if control.controls && control.identifier.blank?
    control.save
      respond_to do |format|
        format.json { render json: control }
      end
  end

  def standard_replicates
    @user = current_user.username
    @order = Order.find(params[:order_id])
    @chemical_list = @order.order_chemical_list.chemical_list
    if @order.using_standard_replicates
      results = remove_standard_replicates
    else
      results = add_standard_replicates
    end
    if results[0]
      hash = {boolean: results[3], non_existing: results[1], existing: results[2], error: false}.to_json
    else
      hash = {error: results[1]}
    end
    respond_to do |format|
      format.json { render json: hash }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.

  def remove_standard_replicates
    @errors = Array.new
    ActiveRecord::Base.transaction do
      begin
        temp_arrays = Control.new.remove_standard_replicates(@order.id)
        @order.update_attributes(:using_standard_replicates => false)
        boolean = @order.using_standard_replicates
        return true, temp_arrays[0], temp_arrays[1], boolean
      rescue => e
        @errors.push(e)
        Rails.logger.error @errors
        return false,@errors
      end
    end
  end

   def add_standard_replicates
     @errors = Array.new
     ActiveRecord::Base.transaction do
       begin
         temp_arrays = Control.new.add_standard_replicates(@order.id, @user)
         @order.update_attributes(:using_standard_replicates => true)
         boolean = @order.using_standard_replicates
         return true, temp_arrays[0], temp_arrays[1], boolean
       rescue => e
         @errors.push(e)
         Rails.logger.error @errors
         return false, @errors
       end
     end
   end

  def set_source_substance
    @source_substance = SourceSubstance.find(params[:id])
    @chemical_list = @source_substance.chemical_list
    @order = Order.find(@chemical_list.order_chemical_list.order_id)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def source_substance_params
    params.require(:source_substance).permit(:fk_chemical_list_id, :new_chemical_list_id, :chemical, :gsid, control_attributes: [:controls])
  end
end
