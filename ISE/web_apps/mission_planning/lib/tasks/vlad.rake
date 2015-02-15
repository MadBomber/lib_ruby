#########################################################################
###
##  File:  vlad.rake
##  Desc:  recipies for use of vlad the deployer
#

require 'vlad'            # Defines generic deployment tasks
require 'vlad/subversion' # Defines the subversion access methods

namespace :vlad do
  desc "Deployment application using 'to=where version=what' on the command line."
  task :deploy do
    # FIXME: check for exist? on the file being loaded
    unless ENV['version']
      ENV['version'] = 'trunk'
      WARNING(["Deployment version not specified; using #{ENV['version']} as default."])
    end
    if ENV['to']
      file_name  = Pathname.new("config")
      file_name += "deploy_#{ENV['to']}.rb"
      if file_name.exist?
        Vlad.load
        @scm = Vlad::Subversion.new
        set :repository, "svn://#{$ISE_QUEEN}/ISE/#{ENV['version']}"
        Kernel.load file_name.to_s
      else
        ERROR(["Unknown deployment destination: #{ENV['to']}"])
      end
    else
      ERROR(["Deployment destination not specified.  Use 'to=where' command line parameter.",
             "Typical destinations are: test, staging and production."])
    end
  end
end

