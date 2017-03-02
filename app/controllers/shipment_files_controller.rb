class ShipmentFilesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_action :shipment_owner, only: [:show, :edit, :update, :destroy, :show_plate, :add_bottles, :finalize_plate]
  before_action :set_shipment_file, only: [:show, :edit, :update, :destroy, :add_bottles, :show_plate, :finalize_plate]
  before_action :set_other_params, only: [:create_external_shipment, :add_bottles]
  before_action :check_shipment_status, only: [:add_bottles, :show_plate,:finalize_plate ]
  include ApplicationHelper
  include OpenExcel


  # GET /shipment_files
  # GET /shipment_files.json
  def index
    if admin? || chemadmin?
      @shipment_files = ShipmentFile.raw_shipments
    elsif cor?
      @shipment_files = ShipmentFile.includes(vendor: :agreements).where(user_id: current_user.id)
    elsif postdoc?
      cors = User.cor(current_user)
      array = Array.new
      cors.each do |cor|
        array.push(cor.cor_id)
      end
      @shipment_files = ShipmentFile.joins(vendor: {agreements: :user}).where(agreements: {user_id: array})
    else
      flash[:notice] = 'Access denied as you are not authorized to view Shipment Files'
      redirect_to root_path
    end
    @external_shipments = ShipmentFile.external
  end

  # GET /shipment_files/1
  # GET /shipment_files/1.json
  def show
  end

  # GET /shipment_files/new
  def new
    @shipment_file = ShipmentFile.new
    @order = Order.all
    @vendors = Vendor.order('name ASC')
  end

  # GET /shipment_files/1/edit
  def edit
    @order = Order.all
  end

  # POST /shipment_files
  # POST /shipment_files.json
  def create
    @shipment_file = ShipmentFile.new(shipment_file_params)
    @shipment_file.user = current_user
    @shipment_file.filename = @shipment_file.file_url.filename
    if @shipment_file.save
      @export = ShipmentFile::DetailExport.new(shipment_file: @shipment_file.id).insert_details_transaction
      if @export[:valid]
      redirect_to shipment_files_url
      check_mapped_other unless @export[:mapped_other].blank?
      flash[:success] = "Shipment File was successfully uploaded"
      mutiple_sheets(@shipment_file.file_url.path)
      else
        render_errors(@export[:errors])
      end
    else
     render_errors(@shipment_file.errors.full_messages)
    end
  end


  def create_external_shipment
    @vendors = establish_vendor_relation
    if params[:add_shipment]
        @shipment_file = ShipmentFile.new(user: @user,
                                          vendor_id: params[:vendor_id].to_i,
                                          task_order_id: params[:task_order_id].to_i,
                                          address_id: params[:address_id].to_i,
                                          order_concentration_id: params[:order_concentration_id].to_i,
                                          plate_detail: params[:plate_detail],
                                          external: 1,
                                          amount: params[:amount],
                                          amount_unit: params[:amount_unit],
                                          ship_id: create_ship_id,
                                          status: "In Progress"
        )

       if @shipment_file.save(validate: false)
         redirect_to add_bottles_shipment_file_path(@shipment_file)
         flash[:success] = "Shipment has been saved, please add bottles to external shipment"
       end
     end
  end

  def add_bottles
    @shipment_bottles = @shipment_file.shipments_bottles
    @results_hash = {:shipment_bottles => @shipment_bottles}
    if params[:add_barcodes]
      bottle_array = Array.new
      list= params[:barcodes].split(",")
      list[0..-1].each do |a|
        bottle_array.push(a)
      end
      @messages = ShipmentsBottle.new.insert_details(bottle_array.collect(&:strip), @shipment_file)
      @results_hash = {:shipment_bottles => @shipment_bottles, :messages => @messages}
        respond_to do |format|
          format.html
          format.js { render 'shipment_files/list_of_bottles', :object => @results_hash}
        end
      end
    end


  def show_plate
    @shipment_bottles = @shipment_file.shipments_bottles
    @results_hash = {:shipment_bottles => @shipment_bottles}
  end

  def edit_record
    @shipment_file= ShipmentFile.find(params[:shipment_file_id])
    @shipment_bottles = @shipment_file.shipments_bottles
    @record= ShipmentsBottle.find(params[:record_id])
    if params[:update_record]
      @record.update_attributes(concentration: params[:concentration],
                                concentration_unit: params[:concentration_unit],
                                amount: params[:amount],
                                amount_unit: params[:amount_unit])
      @results_hash = {:shipment_bottles => @shipment_bottles, :record => @record}
      render 'shipment_files/update_record', :object => @results_hash
    end
  end

  def finalize_plate
    @records = @shipment_file.shipments_bottles
    @total_count = @records.count
    if params[:finalize_shipment]
      ShipmentsBottle.new.finalize(@shipment_file)
      @shipment_file.status = "finalized"
      @shipment_file.save(:validate => false)
      redirect_to shipment_files_path
      flash[:success] = "Shipment was successfully created"
    end
  end


  def update
    respond_to do |format|
      @location_a = @shipment_file.vendor.name
      if @shipment_file.update(comment_params)
        track_shipment_activity(@shipment_file, @location_a, @shipment_file.user, @shipment_file.order_number)
        format.html { redirect_to @shipment_file, success: 'Information was successfully updated.' }
        format.json { render :show, status: :ok, location: @shipment_file }
        flash[:success] = 'Information was successfully updated.'
      else
        error_str = " "
        format.html { render :edit }
        format.json { render json: @shipment_file.errors, status: :unprocessable_entity }
        @shipment_file.errors.full_messages.each do | message|
          error_str += message + "\n"
        end
        flash[:error] = "Validation errors #{ "\n" +error_str}"
      end
    end
  end

  # DELETE /shipment_files/1
  # DELETE /shipment_files/1.json
  def destroy
    @shipment_file.destroy
    respond_to do |format|
      format.html { redirect_to shipment_files_url, notice: 'Shipment file was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_shipment_file
    @shipment_file = ShipmentFile.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def shipment_file_params
    params.require(:shipment_file).permit(:user_id, :filename, :file_url, :file_kilobytes, :comment, :vendor_id, :order_id, :order_number, :mixture, shipments_bottle_attributes: [:barcode,
                                                                                                                                                              :well_id,
                                                                                                                                                              :concentration,
                                                                                                                                                              :concentration_unit,
                                                                                                                                                              :amount,
                                                                                                                                                              :amount_unit
                                                  ])
  end

  def comment_params
    params.require(:shipment_file).permit(:comment, :vendor_id, :order_id, :order_number)
  end

  def set_other_params
    @user = current_user
    @order_concentration =  OrderConcentration.all
    @plate_types = {:one => 96, :two => 384}
  end

  def create_ship_id #this makes sure the ship_id of shipment is generated
    @query = ShipmentFile.where("ship_id LIKE ?", "ES%").order("ship_id DESC").first
    if @query.blank?
      ship_id ="ES100"
    else
      query_string = @query.ship_id.gsub(/ES/, '')
      query_integer = query_string.to_i + 1
      ship_id ="ES"+"#{query_integer}"
    end
    return ship_id
  end

  def check_shipment_status
    @shipment_file = ShipmentFile.find(params[:id])
    unless @shipment_file.status == "In Progress"
      redirect_to shipment_files_path
      flash[:error] = "Shipment File is finalized and can not be edited"
    end
  end

  def shipment_files_access
    if admin? || cor? || postdoc?
      ShipmentFile.external
    else
      ShipmentFile.external.where(user_id: current_user.id)
    end
  end

  def shipment_owner
    if cor?
      unless @shipment_file.user_id == current_user.id
        flash[:notice] = 'Access denied as you are not the owner of this Shipment File'
        redirect_to shipment_files_path
      end
    elsif postdoc?
      cors = User.cor(current_user)
      array = Array.new
      cors.each do |cor|
        array.push(cor.cor_id)
      end
      unless array.include?(@shipment_file.user_id)
        flash[:notice] = 'Access denied as you are not assinged to this Shipment File'
        redirect_to shipment_files_path
      end
    elsif chemcurator? || contractadmin?
      flash[:notice] = 'Access denied as you are not authorized to view Shipment Files'
      redirect_to root_path
    end
  end

  def check_mapped_other
    notice_str = "The Following EPA_Sample_ids required a leading zero for mapping: \n"
    mapped_other = @export[:mapped_other]
    for barcode in mapped_other
      notice_str += barcode.blinded_sample_id + "\n"
    end
    flash[:notice] = "#{notice_str}"
  end

  def render_errors(errors)
    @error_array = Array.new
    shipment_errors(errors)
    @shipment_file = ShipmentFile.new
    @order = Order.all
    @vendors = Vendor.order('name ASC')
    respond_to do |format|
      format.html{ render :new }
      format.js
    end
  end

  def shipment_errors(errors)
    errors.each do | message|
      @error_array.push(message)
    end
  end

end
