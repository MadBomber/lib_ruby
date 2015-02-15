class CreateMpLaunchers < ActiveRecord::Migration
  def self.up
    puts "Create mp_launchers table."
    
    create_table :mp_launchers do |t|
      t.string  :name,                    :null => false
      t.string  :desc
      t.integer :mp_interceptor_id,       :null => false
      t.integer :mp_interceptor_qty,      :null => false, :default => 4
      t.integer :abt_doctrine_id,         :null => false
      t.integer :tbm_doctrine_id,         :null => false

      t.timestamps
    end
  end

  def self.down
    puts "drop mp_launchers table."
    
    drop_table :mp_launchers
  end
end
