#####################################################################
###
##  File: load_pk_tables.rb
##  Desc: Load the global pk_tables hash
#

require 'aadse_utilities'
require 'PkTable'

###################################################################
## Load the Pk Table files

def load_pk_tables

  puts "Ingesting the Pk Tables ..." if $verbose

  start_time = Time.now

  weapons_model_pathdir = $PK_DIR

  raise "WeaponsModel Directory does not exist at: #{weapons_model_pathdir}" unless weapons_model_pathdir.exist?
  raise "WeaponsModel is not a Directory: #{weapons_model_pathdir}" unless weapons_model_pathdir.directory?

  $pk_tables = Hash.new

  weapons_model_pathdir.children.each do |wmdc|

    next unless '.pk' == wmdc.extname

    fn = wmdc.basename.to_s.gsub('.pk', '')
    raise "File name does not conform to naming convention: #{fn}" unless fn.include?('_')

    hs  = Hash.new

    wtp = fn.split('_')

    hs['filepath']  = wmdc.realpath
    hs['platform']  = wtp[0].downcase
    hs['tgt_type']  = wtp[1].downcase
    hs['pk']        = PkTable.new wmdc

    $pk_tables[fn.downcase]  = hs

  end




  if $verbose
    $pk_tables.each_pair do |k,v|
      puts "#{v.class}"
      puts "pk_key: #{k}   filepath: #{v['filepath']}"
      puts "  platform:       #{v['platform']}"
      puts "  tgt_type:       #{v['tgt_type']}"
      puts "  range_max:      #{v['pk'].range_max}  expected: #{v['pk'].expected_range_max} #{(v['pk'].range_max == v['pk'].expected_range_max) ? 'Good' : 'ERROR'}"
      puts "  altitude_max:   #{v['pk'].altitude_max}  expected: #{v['pk'].expected_altitude_max} #{(v['pk'].altitude_max == v['pk'].expected_altitude_max) ? 'Good' : 'ERROR'}"
      puts "  range_scale:    #{v['pk'].range_scale}"
      puts "  altitude_scale: #{v['pk'].altitude_scale}"
      puts "  Pk@half_max:    #{v['pk'].at( (v['pk'].range_max / 2.0) , (v['pk'].altitude_max / 2.0) )}"
    end
  end
  return nil
end ## end of def load_pk_tables



