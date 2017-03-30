class Registrar < ActiveRecord::Base
  # setting up associations
  belongs_to :attack
end
