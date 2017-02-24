class AddTargetToAttacks < ActiveRecord::Migration
  def change
    add_column :attacks, :target, :string
  end
end
