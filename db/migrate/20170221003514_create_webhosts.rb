class CreateWebhosts < ActiveRecord::Migration
  def change
    create_table :webhosts do |t|
      t.string :name
      t.string :attackID

      t.timestamps null: false
    end
  end
end
