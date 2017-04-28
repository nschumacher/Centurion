class CreateRegistrants < ActiveRecord::Migration
  def change
    create_table :registrants do |t|
      t.string :name
      t.string :attackID

      t.timestamps null: false
    end
  end
end
