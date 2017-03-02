class VendorsController < ApplicationController
  before_action :set_vendor, only: [:show, :edit, :update, :new_clone]
  before_filter :authenticate_user!
  load_and_authorize_resource
  include ApplicationHelper
  include ViewVendorFilesHelper
  # GET /vendors
  # GET /vendors.json
  def index
    @vendors = Vendor.all
  end

  # GET /vendors/1
  # GET /vendors/1.json
  def show
  end

  # GET /vendors/new
  def new
    @vendor = Vendor.new
    @button_text = "Create"
  end

  # GET /vendors/1/edit
  def edit
    @button_text = "Update"
  end

  def new_clone
    @button_text = "Clone"
    @clone = true
    @old_vendor = @vendor
  end

  def view_files
    respond_to do |format|
      format.html
    end
  end

  def jstree_data
    path = directory_path
    @results = jstree_result_hash(path)
    respond_to do |format|
      format.json { render json: @results.as_json }
    end
  end

  def open_file
    path = params[:path]
    basename = File.basename(path)
    send_file path, disposition: "inline", filename: basename
  end


  # POST /vendors
  # POST /vendors.json
  def create
    @vendor = Vendor.new(vendor_params)
    @old_vendor = params[:previos_vendor]
    copy_contacts(@old_vendor) unless @old_vendor.blank?
    @vendor.mta_partner = params[:mTAButton].present? ? true : false
    respond_to do |format|
      if @vendor.save
        successful_create(format)
      else
        unless @old_vendor.blank?
          @clone = true
          @old_vendor = Vendor.find(@old_vendor)
        end
        unsuccessful_create(format)
      end
    end
  end

  # PATCH/PUT /vendors/1
  # PATCH/PUT /vendors/1.json
  def update
    boolean = params[:mTAButton].present? ? true : false
    params[:vendor][:mta_partner] = boolean
    respond_to do |format|
      if @vendor.update(vendor_params)
        format.html { redirect_to @vendor, success: 'Vendor was successfully updated.' }
        format.json { render :show, status: :ok, location: @vendor }
        flash[:success] = "Vendor was successfully edited"
      else
        format.html { render :edit }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
        flash[:error] = "Opps something went wrong, please fix me"
        @button_text = "Update"
        vendor_errors
      end
    end
  end

  def view_shipments
    @vendor= Vendor.find(params[:vendor_id])
  end

  def move
    ShipmentFile.move(params[:send_to], params[:shipment_file])
    redirect_to vendors_url
    flash[:success] = "Shipment was successufully moved"
  end

  def task_orders
    vendor = Vendor.find(params[:vendor_id])
    respond_to do |format|
      format.json { render :json => vendor.task_orders }
    end
  end

  def addresses
    vendor = Vendor.find(params[:vendor_id])
    respond_to do |format|
      format.json { render :json => vendor.addresses.joins(contact: :contact_type).where(contact_types: {kind: 'Shipping Recipient'}) }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_vendor
    @vendor = Vendor.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def vendor_params
    params.require(:vendor).permit(:name, :label, :phone1, :phone2, :other_details, :mta_partner)
  end

  def vendor_errors
    error_str = " "
    @vendor.errors.full_messages.each do |message|
      error_str += message + "\n"
    end
    flash.now[:error] = "Validation errors #{ "\n" +error_str}"
  end

  def copy_contacts(old_vendor_id)
    old_vendor = Vendor.find(old_vendor_id)
    unless old_vendor.blank?
      old_vendor.contacts.each do |c|
        @vendor.contacts.build(c.attributes.except('id')).build_address(c.address.attributes.except('id'))
      end
    end
  end

  def successful_create(format)
    path = directory_path
    tmp_string = vendor_directory(path, @vendor)
    format.html { redirect_to @vendor, success: 'Vendor was successfully created.' }
    format.json { render :show, status: :created, location: @vendor }
    flash[:success] = "Vendor was successfully created \n #{tmp_string[1]}"
  end

  def unsuccessful_create(format)
    @button_text = "Try Again"
    if !@old_vendor.blank?
      format.html { render :new_clone }
    else
      format.html { render :new }
    end
    format.json { render json: @vendor.errors, status: :unprocessable_entity }
    vendor_errors
  end

end
