class CreateMpBatteryConfigurations < ActiveRecord::Migration
  def self.up
    puts "Create mp_battery_configurations table."
    
    create_table :mp_battery_configurations do |t|
      t.integer :mp_battery_id,   :null => false
      t.integer :mp_launcher_id,  :null => false
      t.integer :mp_launcher_qty, :null => false, :default => 8

      t.timestamps
    end
  end

  def self.down
    puts "Drop mp_battery_configurations table."
    
    drop_table :mp_battery_configurations
  end
end
