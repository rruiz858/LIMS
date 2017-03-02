json.array!(@shipment_files) do |shipment_file|
  json.extract! shipment_file, :id, :user_id, :filename, :file_url, :file_kilobytes, :comment, :order_number
  json.url shipment_file_url(shipment_file, format: :json)
end
