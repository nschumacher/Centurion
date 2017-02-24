class Case < ActiveRecord::Base
  # setting up associations
  has_many :attacks, dependent: :destroy
  
end
