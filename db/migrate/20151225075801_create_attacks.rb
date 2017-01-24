class CreateAttacks < ActiveRecord::Migration
  def change
    create_table :attacks do |t|
      t.string :case_id
      t.string :client
      t.string :attack_type
      t.string :url
      t.string :detection_time
      t.string :detection_method
      t.string :notes

      t.timestamps null: false
    end
  end
end
