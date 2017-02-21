class FixCaseIdInAttacks < ActiveRecord::Migration
  def change
    remove_column :attacks, :case_id, :string
  end
end
