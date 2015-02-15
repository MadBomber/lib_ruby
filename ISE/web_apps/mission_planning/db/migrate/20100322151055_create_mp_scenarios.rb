class CreateMpScenarios < ActiveRecord::Migration
  def self.up
    puts "Create mp_scenarios table."
    
    create_table :mp_scenarios do |t|
      t.string :name,          :null => false
      t.string :desc
      t.string :idp_name,      :null => false
      t.string :sg_name,       :null => false
      t.datetime :executed_at
      t.string :ise_guid
      t.boolean :selected,     :null => false, :default => 0
      
      t.timestamps
    end
  end

  def self.down
    puts "Drop mp_scenarios table."
    
    drop_table :mp_scenarios
  end
end
