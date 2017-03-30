class Attack < ActiveRecord::Base
  searchkick word_start: [:case_id, :client, :url, :detection_time]

  # setting associations
  belongs_to :case
  has_many :isps
  has_many :registrars
  has_many :webhosts

  accepts_nested_attributes_for :case

  # set keys
  #self.primary_key = 'attackID'

	# this tells searchkick what data to index for searching
	def search_data
		{
			caseID: caseID,
      attackID: attackID,
			url: url,
			registrationDate: registrationDate,
      domain: domain,
      functionality: functionality,
      status: status
		}
	end
end
