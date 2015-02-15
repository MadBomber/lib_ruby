class AddAttachmentsToMpScenario < ActiveRecord::Migration
    def self.up
      add_column :mp_scenarios, :idp_xml_file_name,    :string
      add_column :mp_scenarios, :idp_xml_content_type, :string
      add_column :mp_scenarios, :idp_xml_file_size,    :integer
      add_column :mp_scenarios, :idp_xml_updated_at,   :datetime

      add_column :mp_scenarios, :sg_zip_file_name,    :string
      add_column :mp_scenarios, :sg_zip_content_type, :string
      add_column :mp_scenarios, :sg_zip_file_size,    :integer
      add_column :mp_scenarios, :sg_zip_updated_at,   :datetime
    end

    def self.down
      remove_column :mp_scenarios, :idp_xml_file_name
      remove_column :mp_scenarios, :idp_xml_content_type
      remove_column :mp_scenarios, :idp_xml_file_size
      remove_column :mp_scenarios, :idp_xml_updated_at

      remove_column :mp_scenarios, :sg_zip_file_name
      remove_column :mp_scenarios, :sg_zip_content_type
      remove_column :mp_scenarios, :sg_zip_file_size
      remove_column :mp_scenarios, :sg_zip_updated_at
    end
end

