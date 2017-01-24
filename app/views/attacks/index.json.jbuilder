json.array!(@attacks) do |attack|
  json.extract! attack, :id, :case_id, :client, :attack_type, :url, :detection_time, :detection_method, :notes
  json.url attack_url(attack, format: :json)
end
