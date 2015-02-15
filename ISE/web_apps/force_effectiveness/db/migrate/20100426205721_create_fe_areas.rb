class CreateFeAreas < ActiveRecord::Migration
  def self.up
    create_table :fe_areas do |t|
      t.integer :fe_run_id
      t.string  :label
      t.string  :category

      t.timestamps
    end
  end

  def self.down
    drop_table :fe_areas
  end
end
