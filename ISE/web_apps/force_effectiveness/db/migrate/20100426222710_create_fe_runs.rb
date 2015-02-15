class CreateFeRuns < ActiveRecord::Migration
  def self.up
    create_table(:fe_runs, :id => false) do |t|
      t.integer :id, :options => 'PRIMARY KEY'
      t.integer :mp_scenario_id
      t.integer :mp_tewa_configuration_id
      t.integer :first_frame
      t.integer :last_frame
      
      t.timestamps
    end
  end

  def self.down
    drop_table :fe_runs
  end
end
