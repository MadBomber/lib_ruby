class CreateFeInterceptors < ActiveRecord::Migration
  def self.up
    create_table :fe_interceptors do |t|
      t.integer :fe_run_id
      t.string  :label
      t.string  :category
      t.integer :fe_engagement_id
      t.string  :status

      t.timestamps
    end
  end

  def self.down
    drop_table :fe_interceptors
  end
end
