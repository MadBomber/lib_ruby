class CreateMpLauncherDoctrines < ActiveRecord::Migration
  def self.up
    puts "Create mp_launcher_doctrines table."
    
    create_table :mp_launcher_doctrines do |t|
      t.string :name, :null => false
      t.string :desc

      t.timestamps
    end
  end

  def self.down
    puts "Drop mp_launcher_doctrines table."
    
    drop_table :mp_launcher_doctrines
  end
end
