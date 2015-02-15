class CreateFeThreats < ActiveRecord::Migration
  def self.up
    create_table :fe_threats do |t|
      t.integer :fe_run_id
      t.string  :label
      t.string  :category
      t.integer :target_area_id
      t.integer :source_area_id
      t.string  :status

      t.timestamps
    end
  end

  def self.down
    drop_table :fe_threats
  end
end
