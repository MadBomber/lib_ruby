class RemoveAttachmentsFromMpScenario < ActiveRecord::Migration
    def self.up
      remove_column :mp_scenarios, :idp_xml_file_name
      remove_column :mp_scenarios, :idp_xml_content_type
      remove_column :mp_scenarios, :idp_xml_file_size
      remove_column :mp_scenarios, :idp_xml_updated_at

      remove_column :mp_scenarios, :sg_zip_file_name
      remove_column :mp_scenarios, :sg_zip_content_type
      remove_column :mp_scenarios, :sg_zip_file_size
      remove_column :mp_scenarios, :sg_zip_updated_at
    end

    def self.down
    end
end

