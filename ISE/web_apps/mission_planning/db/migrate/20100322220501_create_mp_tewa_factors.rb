class CreateMpTewaFactors < ActiveRecord::Migration
  def self.up
    puts "Create mp_tewa_factors table."
    
    create_table :mp_tewa_factors do |t|
      t.string :name,     :null => false
      t.string :desc
      t.string :category, :null => false
      

      t.timestamps
    end
  end

  def self.down
    puts "Drop mp_tewa_factors table."
    
    drop_table :mp_tewa_factors
  end
end
