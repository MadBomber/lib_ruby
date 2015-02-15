class CreateMpTewaConfigurations < ActiveRecord::Migration
  def self.up
    puts "Create mp_tewa_configurations table."
    
    create_table :mp_tewa_configurations do |t|
      t.string :name,      :null => false
      t.string :desc
      t.boolean :doctrine, :null => false, :default => 1
      t.boolean :selected, :null => false, :default => 0
      
      t.timestamps
    end
  end

  def self.down
    puts "Drop mp_tewa_configurations table."
    
    drop_table :mp_tewa_configurations
  end
end
