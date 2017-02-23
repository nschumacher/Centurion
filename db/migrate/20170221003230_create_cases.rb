class CreateCases < ActiveRecord::Migration
  def change
    create_table :cases do |t|
      t.string :caseID
      t.string :attackID
      t.string :target

      t.timestamps null: false
    end
  end
end
