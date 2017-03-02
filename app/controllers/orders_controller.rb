class OrdersController < ApplicationController
  include OrdersHelper
  before_filter :authenticate_user!
  before_action :set_order, only: [:show, :destroy, :order_plate_detail, :submit_order, :review_order, :order_overview, :show_plate, :edit, :update, :order_return_show, :order_return_patch, :export_order_file ]
  before_action :order_owner, only: [:show, :show_plate, :order_plate_detail, :submit_order, :order_overview, :edit, :update]
  before_action :set_order_concentration, only: [:new, :create, :edit, :update]
  before_action :if_in_progress, only: [:edit, :update, :show_plate, :order_plate_detail, :review_order]
  before_action :access_to_plate_details, only: [:show_plate]
  before_action :set_controls_and_plate_types, only: [:show_plate, :order_plate_detail]
  load_and_authorize_resource


  def index
    if current_user.role.role_type == "cor"
      @orders = Order.where(user_id: current_user.id)
    elsif current_user.role.role_type == "postdoc"
      cors = User.cor(current_user) ###Class method to find all of the cors assigned to a postdoc
      array = Array.new
      cors.each do |cor|
        array.push(cor.cor_id)
      end
      @orders = Order.where('user_id IN(?)', array)
    elsif current_user.role.role_type == "admin" || current_user.role.role_type == "chemadmin"
      @orders = Order.all
    end
  end

  def show
  end

  def edit
    @task_orders = TaskOrder.all
    @vendors = establish_vendor_relation
    order_concentration_objects
  end

  def new
    @order = Order.new
    @task_orders = TaskOrder.all
    @vendors = establish_vendor_relation
    order_concentration_objects
  end

  def create
    @order = Order.new(order_params)
    @order.user = current_user
    @order.order_status_id = OrderStatus.find_by_name("created").id
    respond_to do |format|
      if @order.save
        @new_chemical_list = ChemicalList.new(list_abbreviation: "CTORDER#{@order.id}", list_name: "ChemTrack Order Number #{@order.id} Chemical List",
                                                ncct_contact: @order.user.f_name, source_contact: @order.user.f_name, source_contact_email: @order.user.email,
                                                list_type: "test", list_update_mechanism: "test", list_accessibility: "PRIVATE", curation_complete: "test", source_data_updated_at: Time.now,
                                                created_by: @order.user.username, updated_by: @order.user.username)
        @new_chemical_list.save
        @order.build_order_chemical_list(chemical_list_id: @new_chemical_list.id).save
        format.html { render :edit }
        order_concentration_objects
        @task_orders = TaskOrder.all
        @vendors = establish_vendor_relation
        flash.now[:success] = 'Order was successfully created.'
      else
        @vendors = establish_vendor_relation
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
        flash.now[:error] = "Something went wrong"
      end
    end
  end

  def update
    respond_to do |format|
      @task_orders = TaskOrder.all
      @vendors = establish_vendor_relation
      order_params.merge(order_status_id: OrderStatus.find_by_name("created").id)
      if @order.update(order_params)
        order_concentration_objects
        format.html { render :edit }
        flash.now[:success] = "Order was successfully updated"
      else
        format.html { render :edit }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
        order_errors
        order_concentration_objects
      end
    end
  end

  def show_plate
    @order_plate_detail = @order.order_plate_detail
    @order_plate_detail ||= OrderPlateDetail.new
    @button_param = button_name
    @order_plate_detail.new_record? ? @plate_type = PlateType.new : @plate_type = @order_plate_detail.plate_type
    plate_kind
  end

  def order_plate_detail
    @plate_detail_param = params[:plate_detail]
    unless @plate_detail_param.blank?
      begin
        ActiveRecord::Base.transaction do
          if params[:new_detail]
            @order.build_order_plate_detail(user_id: @order.user_id, plate_type_id: params[:plate_detail], empty: params[:empty], solvent: params[:solvent], control: params[:control]).save
          elsif params[:update_detail]
            @order.order_plate_detail.update_attributes(plate_type_id: params[:plate_detail], empty: params[:empty], solvent: params[:solvent], control: params[:control])
          end
        end
      rescue => e
        @errors = ""
        @errors << e.to_s
        Rails.logger.error @errors
      else
        update_order_status(@order, OrderStatus.find_by_name('plate_details'))
      end
    end
    @order_plate_detail = @order.order_plate_detail
    @plate_type = @order_plate_detail.plate_type
    @button_param = button_name
    plate_kind
    respond_to do |format|
      format.html
      format.js
    end
  end

  def order_overview
    if !(@chemical_list.source_substances.blank?) || (in_review?) || (submitted?)
      @plate_count = OrderPlateDetail.plate_count(@order.order_plate_detail.plate_type, @chemical_list.source_substances.count)
      @available_results =  SourceSubstance.available(@chemical_list.id, @order.amount, @order.order_concentration.concentration)
    else
      redirect_to_back(orders_path)
      flash[:notice] = "Action is not available at this time "
    end
  end

  def review_order
    if plate_details? #action is not available if the status of order is not at the plate detail status
      @rejected = params[:rejected]
      begin
        ActiveRecord::Base.transaction do
          @order.resubmitted = true if @rejected
          update_order_status(@order, OrderStatus.find_by_name('review'))
          create_comment(order_comments_params, current_user)
        end
      rescue => e
        @errors = ""
        @errors << e.to_s
        Rails.logger.error @errors
        @order = @order.reload
      else
        @role = Role.find_by_role_type("chemadmin")
        @chemadmins = User.where(role_id: @role.id)
        @chemadmins.each do |chemadmin|
          OrderMailer.order_confirmation(@order, chemadmin, current_user).deliver_now
        end
      end
      respond_to do |format|
        format.js
        format.html
        format.text
      end
    else
      redirect_to_back(orders_path)
      flash[:notice] = "Action is not available at this time "
    end
  end

  def order_comments_show
    @comments = @order.order_comments
    respond_to do |format|
      format.js { render 'orders/order_comments', :object => @order }
    end
  end

  def order_return_patch
    if in_review? #action is not available if the status of order is not at the in_review status
      @order_comments = @order.order_comments.build(body: order_comments_params[:body])
      @order_comments.created_by = current_user.username
      begin
        ActiveRecord::Base.transaction do
          @order_comments.save!
          @order.rejected = true
          @order.resubmitted = false if @order.rejected
          update_order_status(@order, OrderStatus.find_by_name('plate_details'))
        end
      rescue => e
        @errors = ""
        @errors << e.to_s
        Rails.logger.error @errors
        @order = @order.reload
      else
        chemadmin = current_user
        OrderMailer.order_return_mail(@order, chemadmin, @order_comments).deliver_now
      end
      respond_to do |format|
        format.js
        format.html
        format.text
      end
    else
      redirect_to_back(orders_path)
      flash[:notice] = "Action is not available at this time "
    end
  end

  def submit_order
    if in_review?  #action is not available if the status of order is not at the in_review status
      @order.rejected = false if @order.rejected
      if update_order_status(@order, OrderStatus.find_by_name('submitted'))
        @success = 'Order was successfully submitted'
      else
       @error = 'Order was not submitted'
      end
      respond_to do |format|
        format.html
        format.js
      end
    else
      redirect_to_back(orders_path)
      flash[:notice] = 'This action is not available at this time'
    end
  end

  def destroy
    unless cor? && submitted?
      @order.destroy
      respond_to do |format|
        format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      redirect_to orders_path
      flash[:notice] = 'You cannot delete an order that has been submitted'
    end
  end

  def export_order_file
   @order = Order.find(params[:order_id])
   @all_chemicals = @order.available_chemicals + @order.not_available_chemicals
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => ' All requested Chemicals'
    sheet2 = book.create_worksheet :name => 'Order Information'
    sheet1.row(0).concat %w{
    gsid
    preferred_name
    casrn
    DTXSID
    }
    @all_chemicals.each_with_index do |chemical, i|
      sheet1.row(i+1).replace [chemical["gsid"],
                               chemical["name"],
                               chemical["cas"],
                               chemical["dtxsid"]]
    end
    sheet2.row(0).concat %w{
    Vendor
    Address
    Country
    State
    City
    Zipcode
      }
    query = Order.joins(:vendor).joins(:address).select('vendors.label as label,orders.task_order_id as task_order, addresses.zip as zip,'\
                                                        'addresses.address1 as address1, addresses.country as country, addresses.city as city,'\
                                                        'addresses.state as state').find(@order.id)

    sheet2.row(1).replace [query.label, query.address1, query.country, query.state, query.city, query.zip]
    sheet2.row(1).height = 50
    sheet2.column(0).width = 30
    sheet2.column(1).width = 50
    sheet2.column(2).width = 30
    format = Spreadsheet::Format.new :weight => :bold
    sheet2.row(0).default_format = format
    download_file(book)
  end

  private
  # Use callbacks to share common setup or constraints between actions.

  def download_file(book)
    date = Time.now.strftime('%Y%m%d')
    filename = "order_review_#{date}.xls"
    spreadsheet = StringIO.new
    book.write spreadsheet
    send_data spreadsheet.string, :filename => filename, :type => "application/vnd.ms-excel"
  end

  def order_errors
    error_str = " "
    @order.errors.full_messages.each do |message|
      error_str += message + "\n"
    end
    flash[:error] = "Validation errors #{ "\n" +error_str}"
  end

  def access_to_plate_details
    if in_progress? && !(admin?)
      @order_amount = @order.amount
      @order_concentration = @order.order_concentration.concentration
      @available = SourceSubstance.available(@chemical_list.id, @order_amount, @order_concentration)
      @no_hits = SourceSubstance.no_hits(@chemical_list.id)
      @results_hash = {"available" => @available, "not_available" => @not_available, "duplicates" => @duplicates, "no_hits" => @no_hits}
      unless @available.present?&&@no_hits.empty?
        redirect_to_back(orders_path)
        flash[:notice] = 'You are unable to access this page at this time'
      end
    end
  end

  def order_params
    params.require(:order).permit(:vendor_id, :task_order_id, :address_id, :order_concentration_id,  :amount, :dried_down )
  end

  def order_comments_params
    params.permit(:body, :rejected)
  end

  def set_order
    @order = Order.find(params[:id])
    @chemical_list = @order.order_chemical_list.chemical_list
  end

  def set_order_concentration
    @order_concentration =  OrderConcentration.all
  end

  def if_in_progress
    unless can_edit_order?
      redirect_to_back(orders_path)
      flash[:notice] = 'You are unable to make changes at this time'
    end
  end
  def order_concentration_objects
    @neat = OrderConcentration.find_by_concentration('0').id
    @twenty = OrderConcentration.find_by_concentration('20').id
    @onehundred = OrderConcentration.find_by_concentration('100').id
  end

  def set_controls_and_plate_types
    @plate_types = PlateType.all
    @controls = Control.order_controls(@order.id)
  end

  def button_name
    @order_plate_detail.plate_type.blank? ? 'new_detail' : 'update_detail'
  end

  def create_comment(params, user)
    if params[:rejected]
      order_comments = @order.order_comments.build(body: order_comments_params[:body])
      order_comments.created_by = user.username
      order_comments.save!
    end
  end

  def plate_kind
    @plate_kinds = Hash.new
    @plate_kinds[:vials]= find_plate_kind('vials')
    @plate_kinds[:plate_96] =find_plate_kind('96 plate')
    @plate_kinds[:plate_384] = find_plate_kind('384 plate')
  end

  def find_plate_kind(kind)
    PlateType.find_by('label = ?', kind).id.to_s
  end

end
