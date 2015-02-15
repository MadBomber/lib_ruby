class CreateMpInterceptors < ActiveRecord::Migration
  def self.up
    puts "Create mp_interceptors table."
    
    create_table :mp_interceptors do |t|
      t.string  :name,                 :null => false
      t.string  :desc
      t.integer :pk_air,               :null => false, :default => 100
      t.integer :pk_space,             :null => false, :default => 100
      t.integer :velocity,             :null => false, :default => 5000
      t.integer :cost,                 :null => false, :default => 0
      t.integer :eng_zone_scale_air,   :null => false, :default => 1
      t.integer :eng_zone_scale_space, :null => false, :default => 1

      t.timestamps
    end
  end

  def self.down
    puts "drop mp_interceptors table"
    
    drop_table :mp_interceptors
  end
end
