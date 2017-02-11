class Attack < ActiveRecord::Base
  searchkick word_start: [:case_id, :client, :url, :detection_time]

	# this tells searchkick what data to index for searching
	def search_data
		{
			case_id: case_id,
			client: client,
			url: url,
			detection_time: detection_time
		}
	end
end
