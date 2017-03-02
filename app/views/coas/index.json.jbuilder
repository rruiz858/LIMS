json.array!(@coas) do |coa|
  json.extract! coa, :id, :filename, {file_url:[]}, :file_kilobytes, :user_id, :bottle_id
  json.url coa_url(coa, format: :json)
end
