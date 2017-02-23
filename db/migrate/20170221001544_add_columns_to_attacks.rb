class AddColumnsToAttacks < ActiveRecord::Migration
  def change
    add_column :attacks, :caseID, :string
    add_column :attacks, :attackID, :string
    add_column :attacks, :functionality, :string
    add_column :attacks, :domain, :string
    add_column :attacks, :dateRecorded, :string
    add_column :attacks, :registrationDate, :string
    add_column :attacks, :expireryDate, :string

    remove_column :attacks, :case_id, :string
    remove_column :attacks, :client, :string
    remove_column :attacks, :attack_type, :string
    remove_column :attacks, :detection_time, :string
    remove_column :attacks, :detection_method, :string
  end
end
