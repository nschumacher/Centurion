class AddImageToAttacks < ActiveRecord::Migration
  def change
    add_column :attacks, :image, :string
  end
end
