class AddAutoEngageAndRuntypeFieldsToMpScenario < ActiveRecord::Migration
  def self.up
    add_column :mp_scenarios, :auto_engage_tbm,   :boolean, :default => false
    add_column :mp_scenarios, :auto_engage_abt,   :boolean, :default => false
    add_column :mp_scenarios, :man_in_the_loop,   :boolean, :default => true
  end

  def self.down
    remove_column :mp_scenarios, :auto_engage_tbm,   :boolean, :default => false
    remove_column :mp_scenarios, :auto_engage_abt,   :boolean, :default => false
    remove_column :mp_scenarios, :man_in_the_loop,   :boolean, :default => true
  end
end
