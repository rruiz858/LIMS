json.array!(@orders) do |order|
  json.extract! order, :id, :user_id, :vendor_id, :task_order_id, :concentration, :amount, :amount_unit
  json.url order_url(order, format: :json)
end
