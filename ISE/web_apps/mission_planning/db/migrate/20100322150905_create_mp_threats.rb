class CreateMpThreats < ActiveRecord::Migration
  def self.up
    puts "Create mp_threats table."
    
    create_table :mp_threats do |t|
      t.string :name,           :null => false
      t.string :desc
      t.string :track_category, :null => false, :default => 'space'
      t.float  :effects_radius, :null => false, :default => 1.0

      t.timestamps
    end
  end

  def self.down
    puts "Drop mp_threats table."
    
    drop_table :mp_threats
  end
end
