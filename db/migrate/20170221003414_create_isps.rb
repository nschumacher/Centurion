class CreateIsps < ActiveRecord::Migration
  def change
    create_table :isps do |t|
      t.string :name
      t.string :attackID

      t.timestamps null: false
    end
  end
end
