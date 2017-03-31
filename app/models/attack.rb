class Attack < ActiveRecord::Base
  searchkick word_start: [:case_id, :client, :url, :detection_time]
  require 'screencap'

	# this tells searchkick what data to index for searching
	def search_data
		{
			caseID: caseID,
			url: url,
      registrationDate: registrationDate
		}
	end

  def screenshot
    f = Screencap::Fetcher.new(self.url)
    screen_shot = f.fetch
    loc = "~/#{self.url}.jpg"
    #ss = f.fetch(:output => loc)
  end
end
