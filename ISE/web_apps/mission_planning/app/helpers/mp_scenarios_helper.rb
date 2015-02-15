module MpScenariosHelper

  #####################################################################################
  def sync_idp_sg_service_alive?
    begin
      $sync_idp_sg_service.alive?
    rescue DRb::DRbConnError
      STDERR.puts "got DRb::DRbConnError"
      false
    end    
  end
  
  #####################################################################################
  def get_remote_idp_dir_names
    if sync_idp_sg_service_alive?
      $sync_idp_sg_service.idp_scenario_names
    else
      ["=== no-idp ==="]
    end
  end

  #####################################################################################
  def get_remote_sg_dir_names
    if sync_idp_sg_service_alive?
      $sync_idp_sg_service.sg_scenario_names
    else
      ["=== no-sg ==="]
    end
  end

  #####################################################################################
  def get_sub_directories(a_path)
    sub_directories = Array.new
    a_path.children.each do |c|
      sub_directories << c.basename.to_s if c.directory? and '.svn' != c.basename.to_s
    end
    return sub_directories
  end

  #####################################################################################
  def idp_directories
    return (get_sub_directories($IDP_DIR)+get_remote_idp_dir_names).flatten.uniq.sort
  end

  #####################################################################################
  def sg_directories
    return (get_sub_directories($SG_DIR)+get_remote_sg_dir_names).flatten.uniq.sort
  end

end ## end of module MpScenariosHelper
