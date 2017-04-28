json.extract! registrant, :id, :name, :attackID, :created_at, :updated_at
json.url registrant_url(registrant, format: :json)