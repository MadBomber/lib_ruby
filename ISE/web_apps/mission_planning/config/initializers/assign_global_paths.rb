####################################################################
###
##	File:  assign_global_paths.rb
##	Desc:  Create global pathnames from environment variables
#

require 'pathname'

$AADSE_ROOT = Pathname.new ENV['AADSE_ROOT']
$IDP_DIR    = Pathname.new ENV['IDP_DIR']
$SG_DIR     = Pathname.new ENV['SG_DIR']


