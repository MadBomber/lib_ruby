####################################################################
###
##	File:  sync_idp_sg_service.rb
##	Desc:  Initialize access to the SyncIdpSg service
#

require 'iniparse'
require 'pathname'
require 'drb'

ENV['RSYNC_USER']     = 'ise'
ENV['RSYNC_PASSEORD'] = 'iseisnice'

# make sure that the 'ise' user has access to all the IDP/SG files/directories in $DATA_DIR

system("chmod -R 777 #{$IDP_DIR}")
system("chmod -R 777 #{$SG_DIR}")

config_file = Pathname.new(ENV['AADSE_ROOT']) + 'config' + 'project.ini'

begin
  $OPTIONS[:services] = IniParse.open(config_file.to_s)['services']
rescue
  $OPTIONS[:services] = nil
end

if $OPTIONS[:services].nil?
  puts "There was no 'services' section in the project.ini file."
else

  $sync_idp_sg_ip_port = $OPTIONS[:services]['sync_idp_sg_service']

  if $sync_idp_sg_ip_port.nil?
    puts "There was no 'sync_idp_sg_service' in the 'services' section of the project.ini file."
  else

    # SMELL: This will produce an exception in irb when the
    #        service is not available; BUT, outside of irb
    #        it does not produce an exception.
    $sync_idp_sg_service = DRbObject.new_with_uri("druby://#{$sync_idp_sg_ip_port}")

    # So, we add our own alive? method to the service to force the exception
    begin
      $sync_idp_sg_service.alive?
    rescue DRb::DRbConnError
      puts "The sync_idp_sg service is not alive."
      # exit(3)
    end

  end

end

