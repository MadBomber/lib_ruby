class CreateMpBatteries < ActiveRecord::Migration
  def self.up
    puts "Create mp_batteries table."
    
    create_table :mp_batteries do |t|
      t.string :name
      t.string :desc
      
      t.timestamps
    end
  end

  def self.down
    puts "Drop mp_batteries table."
    
    drop_table :mp_batteries
  end
end
