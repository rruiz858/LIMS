module OrdersHelper
include UsersHelper

  def created?
  @order.order_status &&  @order.order_status.name == "created"
  end

  def adding_chemicals?
    @order.order_status && @order.order_status.name == "adding_chemicals"
  end

  def plate_details?
    @order.order_status &&  @order.order_status.name == "plate_details"
  end
  def in_progress?
    created? || adding_chemicals? || plate_details?
  end

  def in_review?
    @order.order_status && @order.order_status.name == "review"
  end

  def submitted?
    @order.order_status && @order.order_status.name == "submitted"
  end

  def can_edit_order?
     (admin? || chemadmin? || in_progress?) ? true : false
  end

end
