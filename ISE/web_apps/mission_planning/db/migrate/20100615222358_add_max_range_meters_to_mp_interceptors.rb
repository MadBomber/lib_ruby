class AddMaxRangeMetersToMpInterceptors < ActiveRecord::Migration
  def self.up
      add_column :mp_interceptors, :max_range_meters,    :integer, :default => 5000
  end

  def self.down
      remove_column :mp_interceptors, :max_range_meters
  end
end
