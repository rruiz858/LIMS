class AgreementsController < ApplicationController
  include ViewVendorFilesHelper
  before_filter :authenticate_user!
  before_action :set_agreement, only: [ :show, :edit, :update, :destroy, :manage_agreements, :add_documents, :generate_pdf]
  before_action :check_status, only: [:manage_agreements, :finalize_agreement ]
  before_action :permission, only: [:index]
  load_and_authorize_resource
  before_action :agreement_owner, only: [:edit, :update, :manage_agreements, :show]

  def index
    if chemadmin? || contractadmin? || admin?
      @agreements = Agreement.all
    else
      @agreements = Agreement.where(user_id: current_user.id)
    end
  end

  def new
    @vendor = Vendor.find(params[:vendor_id])
    @agreement = Agreement.new()
    @cors =  User.joins(:role).where("role_type = 'cor'")
    @button_text = "Create"
  end

  def show
    @task_orders = @agreement.task_orders
  end

  def edit
    @cors =  User.joins(:role).where("role_type = 'cor'")
    @vendor = Vendor.find(params[:vendor_id])
    @agreement = Agreement.find(params[:id])
    @statuses = AgreementStatus.where.not('status = ? OR status = ?' ,'Active', 'Revoked' )
    @revoked = AgreementStatus.where(status: "Revoked")
    @button_text = "Update"
  end


  def create
    @agreement = Agreement.new(agreement_params)
    @agreement.created_by = current_user.username
    @vendor = Vendor.find(params[:vendor_id])
    create_rank(@vendor, @agreement)
    respond_to do |format|
      if @agreement.save
        path = directory_path
        tmp_string = agreement_directory(path, @agreement)
        track_activity @agreement
        format.html { redirect_to @vendor, success: 'Agreement was successfully created.' }
        format.json { render :show, status: :created, location: @agreement }
        flash[:success] = "Agreement was successfully created \n #{tmp_string[1]}"
      else
        @cors =  User.joins(:role).where("role_type = 'cor'")
        format.html { render :new }
        format.json { render json: @agreement.errors ,status: :unprocessable_entity }
        error_str = " "
        @agreement.errors.full_messages.each do | message|
          error_str += message + "\n"
        end
        flash[:error] = "Validation errors #{ "\n" +error_str}"
      end
    end
  end


  def update
    @agreement.updated_by = current_user.username
    respond_to do |format|
      if @agreement.update(agreement_params)
        track_activity @agreement
        @vendor = Vendor.find(params[:vendor_id])
        format.html { redirect_to :back, success: 'Agreement was successfully updated.' }
        format.json { render :show, status: :ok, location: @agreement }
        flash[:success] = "Agreement was successfully updated"
      else
        format.html { redirect_to :back }
        format.json { render json: @agreement.errors, status: :unprocessable_entity }
        error_str = " "
        @agreement.errors.full_messages.each do | message|
          error_str += message + "\n"
        end
        flash[:error] = "Validation errors #{ "\n" +error_str}"
      end
    end
  end

  def add_documents
    @agreement = Agreement.find(params[:id])
    @vendor = Vendor.find(params[:vendor_id])
    respond_to do |format|
      @document= @agreement.agreement_documents.build(file_url: params[:agreement][:file_url],
                                                    filename:  params[:agreement][:file_url].original_filename,
                                                    agreement_id: params[:agreement][:id],
                                                    created_by: current_user.username)
      if @document.save
        track_activity @document
        format.html {redirect_to manage_agreements_vendor_agreement_path}
        format.js {}
        format.json {render 'agreements/manage_agreements' }
        flash[:success] = "Document was successfully uploaded"
      end
    end
  end
  def manage_agreements
    @vendor = Vendor.find(params[:vendor_id])
    @agreement = Agreement.find(params[:id])
    @final_status = AgreementStatus.find_by_status('Active')
    temp_array = Activity.where('trackable_id = ? AND trackable_type = ?', @agreement.id, 'Agreement') + Activity.document_activities(@agreement)
    @activities = (temp_array.sort_by{|k| k["created_at"]}).reverse!
  end


  def destroy
    @agreement.destroy
    respond_to do |format|
      @vendor = Vendor.find(params[:vendor_id])
      format.html { redirect_to @vendor, success: 'Agreement was successfully destroyed.' }
      format.json { head :no_content }
      flash[:success] = "Agreement was successfully destroyed."
    end
  end

  def generate_pdf
    @vendor = Vendor.find(params[:vendor_id])
    temp_array = Activity.where("trackable_id = ? AND trackable_type = ?",  @agreement.id, "Agreement") + Activity.document_activities(@agreement)
    @activities = (temp_array.sort_by{|k| k["created_at"]}).reverse!
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = 'Fri, 01 Feb 1991'
    respond_to do |format|
     format.pdf do
       render pdf: "agreement_#{@vendor.name}",
       template: 'agreements/pdf/agreement_overview.pdf.html.erb'
     end
    end
  end

  def finalize_agreement
    if @agreement.update(agreement_params)
      @vendor = Vendor.find(params[:vendor_id])
      redirect_to @vendor
      track_activity @agreement
      flash[:success] = "Agreement was successfully finalized."
    else
      error_str = " "
      redirect_to :back
      @agreement.errors.full_messages.each do | message|
        error_str += message + "\n"
      end
      flash[:error] = "#{error_str}"
    end
  end

  private

  def agreement_owner
    if cor?
      unless @agreement.user_id == current_user.id
        flash[:notice] = 'Access denied as you do not have any agreements associated with this vendor'
        redirect_to :back
      end
    end
  end

  def create_rank(vendor, agreement)
    rank = vendor.agreements.maximum("rank").to_i
    rank == 0 ? agreement.rank = 1 : agreement.rank = rank + 1
  end

  def set_agreement
    @agreement = Agreement.find(params[:id])
    @vendor = Vendor.find(params[:vendor_id])
  end

  def agreement_params
    params.require(:agreement).permit(:name, :agreement_status_id, :vendor_id, :user_id, :description, :expiration_date, :active, :revoke_reason, agreement_documents_attributes: [:id, :agreement_id, :file_size, :file_name, :created_by, :file_url])
  end

  def check_status
    @agreement = Agreement.find(params[:id])
    if (@agreement.active) && (current_user.role.role_type != "admin")
     redirect_to vendor_path(@agreement.vendor_id)
     flash[:error] = "Agreement has been finalized and cannot be edited"
    end
  end

  def permission
    if postdoc? || chemcurator?
      redirect_to root_path
      flash[:error] = "Access denied as you are unauthorized to view all Agreements"
    end
  end

end