class AddRandomThreatCountToMpScenarios < ActiveRecord::Migration
  def self.up
    add_column :mp_scenarios, :random_threat_count,    :integer, :default => 0
  end

  def self.down
    remove_column :mp_scenarios, :random_threat_count
  end
end
