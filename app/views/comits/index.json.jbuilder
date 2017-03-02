json.array!(@comits) do |comit|
  json.extract! comit, :id, :filename, :file_url, :file_kilobytes, :file_record_count, :added_by_user_id
  json.url comit_url(comit, format: :json)
end
