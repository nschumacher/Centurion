class AddWhoisColumnToAttacks < ActiveRecord::Migration
  def change
    add_column :attacks, :whois_text, :string
  end
end
