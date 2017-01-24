class AddStatusColumnToAttacks < ActiveRecord::Migration
  def change
    add_column :attacks, :status, :string
  end
end
