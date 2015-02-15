class CreateMpTewaValues < ActiveRecord::Migration
  def self.up
    puts "Create mp_tewa_values table."
    
    create_table :mp_tewa_values do |t|
      t.integer :mp_tewa_factor_id,        :null => false
      t.integer :mp_tewa_configuration_id, :null => false
      t.integer :value,                    :null => false, :default => 0
      
      t.timestamps
    end
  end

  def self.down
    puts "Drop mp_tewa_values table."
    
    drop_table :mp_tewa_values
  end
end
