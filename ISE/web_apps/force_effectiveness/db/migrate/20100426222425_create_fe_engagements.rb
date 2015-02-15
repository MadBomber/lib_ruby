class CreateFeEngagements < ActiveRecord::Migration
  def self.up
    create_table :fe_engagements do |t|
      t.integer :fe_run_id
      t.integer :fe_launcher_id
      t.integer :fe_threat_id
      t.string  :status

      t.timestamps
    end
  end

  def self.down
    drop_table :fe_engagements
  end
end
