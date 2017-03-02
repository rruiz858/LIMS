json.array!(@vendors) do |vendor|
  json.extract! vendor, :id, :name, :label, :phone1, :phone2, :other_details
  json.url vendor_url(vendor, format: :json)
end
