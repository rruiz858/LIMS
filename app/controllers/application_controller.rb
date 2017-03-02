class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_order
  include UsersHelper

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to :back
  end

  def track_activity(trackable)
      current_user.activities.create! action: params[:action], trackable: trackable
  end

  def open_spreadsheet(file_url)
    case File.extname(file_url) #File.extname returns the extention of the file. The case statement operates when the file extention matches to statement next to case
      when ".xls" then
        Roo::Excel.new(file_url, packed: nil, file_warning: :ignore)
      when ".xlsx" then
        Roo::Excelx.new(file_url, packed: nil, file_warning: :ignore)
      else
        raise "Unknown file type: #{file_url}"
    end
  end

  def authorize_admin
    return unless !current_user.role.role_type == "admin"
    redirect_to root_path
  end


  def establish_vendor_relation
    @current_user = current_user
    if admin? || chemadmin?
      Vendor.select('SQL_CACHE id, name').order('name ASC').all
    else
      @current_user.vendors.order('name ASC')
    end
  end

  def directory_path
    ENV['DIR_PATH']
  end

  def admin_permissions
    unless chemadmin? || admin?
      flash[:notice] = 'Uh-Oh you are being naughty'
      redirect_to root_path
    end
  end

  def order_owner
    if cor?
      unless @order.user_id == current_user.id
        flash[:notice] = 'Access denied as you are not the owner of this Order'
        redirect_to orders_path
      end
    elsif postdoc?
      cors = User.cor(current_user) ###Class method to find all of the cors assigned to a postdoc
      array = Array.new
      cors.each do |cor|
        array.push(cor.cor_id)
      end
      unless array.include?(@order.user_id)
        flash[:notice] = 'Access denied as you are not assinged to this Order'
        redirect_to orders_path
      end
    elsif chemcurator? || contractadmin?
      unless @order.user_id == current_user.id
        flash[:notice] = 'Access denied as you are not authorized to manage Orders'
        redirect_to root_path
      end
    end
  end

  def update_order_status(order, status)
    order.order_status = status
    order.save
  end

  def redirect_to_back(url)
     url ||= root_url
    if request.env["HTTP_REFERER"].present? and request.env["HTTP_REFERER"] != request.env["REQUEST_URI"]
      redirect_to :back
    else
      redirect_to (url)
    end
  end

end
