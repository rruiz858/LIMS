class ContactsController < ApplicationController
  before_action :set_contact, only: [ :edit, :update, :destroy]
  before_filter :authenticate_user!
  before_filter :check_contact_status, only: [:new, :edit]
  load_and_authorize_resource
  before_action :contact_owner, only: [:edit, :update, :new, :create]

  def new
    @vendor = Vendor.find(params[:vendor_id])
    @contact = Contact.new()
    @contact.build_address
    @countries = array_of_countries
    @button_text = "Create"
  end

  def edit
    @vendor = Vendor.find(params[:vendor_id])
    @contact = Contact.find(params[:id])
    @countries = array_of_countries
    @button_text = "Update"
  end


  def address
    @address = Contact.find(params[:id]).address
  end

  def create
    @contact = Contact.new(contact_params)
    @vendor = Vendor.find(params[:vendor_id])
    respond_to do |format|
      if @contact.save
        format.html { redirect_to @vendor, success: 'Contact was successfully created.' }
        format.json { render :show, status: :created, location: @contact }
        flash[:success] = "Contact & Address was successfully created"
      else
        @countries = array_of_countries
        format.html { render :new }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
        contact_errors
      end
    end
  end

  def update
    respond_to do |format|
      if @contact.update(contact_params)
        @vendor = Vendor.find(params[:vendor_id])
        format.html { redirect_to @vendor, success: 'Contact was successfully updated.' }
        format.json { render :show, status: :ok, location: @contact }
        flash[:success] = "Contact was successfully updated"
      else
        @countries = array_of_countries
        format.html { render :edit }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
        contact_errors
      end
    end
  end

  def destroy
    @contact.destroy
    respond_to do |format|
      @vendor = Vendor.find(params[:vendor_id])
      format.html { redirect_to @vendor, success: 'Contact was successfully destroyed.' }
      format.json { head :no_content }
      flash[:success] = "Contact was successfully destroyed."
    end
  end


  def states
    country = ISO3166::Country.find_country_by_name(params[:country])
    country.subdivisions
    states_array = Array.new
    states_array[0]= {:state => 'N/A'} unless country.to_s == 'United States'
    country.states.each do |key, value|
      states_array << {:state => value['name']}
    end
    respond_to do |format|
      format.json { render :json => states_array }
    end
  end

  private

  def contact_owner
    if cor?
      @vendor = Vendor.find(params[:vendor_id])
      owner = Agreement.where(user_id: current_user.id).where(vendor_id: @vendor)
      unless owner.present?
        flash[:notice] = 'Access denied as you do not have any agreements associated with this vendor'
        redirect_to :back
      end
    end
  end

  def contact_errors
    error_str = " "
    @contact.errors.full_messages.each do |message|
      error_str += message + "\n"
    end
    flash.now[:error] = "Validation errors #{ "\n" +error_str}"
  end

  def check_contact_status
    #if statuses are not created, they are created here
    tmp_array = Array.new
    kinds = ['Project Manager', 'Shipping Recipient', 'Other']
    query = ContactType.where('kind IN (?)', kinds)
    kinds.each {|status| tmp_array.push(status) unless query.detect{|k| k["kind"] == status}}
    unless tmp_array.blank?
     create_array = Array.new
     tmp_array.each do |status|
       tmp_hash = Hash.new
       tmp_hash[:kind] = status
       create_array.push(tmp_hash)
     end
     ContactType.create(create_array)
    end
    @contact_types = ContactType.all
  end

  def set_contact
    @contact = Contact.find(params[:id])
    @vendor = Vendor.find(params[:vendor_id])
  end

  def contact_params
    params.require(:contact).permit(:first_name, :last_name, :email, :title, :department, :phone1, :phone2, :fax, :cell, :other_details, :vendor_id, :contact_type_id,
    address_attributes:[:id, :address1, :address2, :country, :state,  :city,  :zip, :other_details, :contact_id, :override_city])
  end

  def array_of_countries
    countries = ISO3166::Country.all
    translated_countries = []
    countries.each do |c|
      translated_countries << c.translations['en']
    end
    translated_countries.sort_by! {|country| country.to_s}
    translated_countries.reject(&:blank?)
  end

end