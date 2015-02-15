class AddScenarioNamesToRunsTable < ActiveRecord::Migration
  def self.up
    add_column :fe_runs, :mps_idp_name, :string, :default => ""
    add_column :fe_runs, :mps_sg_name,  :string, :default => ""
    add_column :fe_runs, :mptc_name,    :string, :default => ""
  end

  def self.down
    remove_column :fe_runs, :mps_idp_name, :string, :default => ""
    remove_column :fe_runs, :mps_sg_name,  :string, :default => ""
    remove_column :fe_runs, :mptc_name,    :string, :default => ""
  end
end
