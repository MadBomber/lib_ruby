#!/usr/bin/env ruby
########################################
## find those parameters files.
## TODO: Add the test/unit infrastructure

$verbose = false

require 'Parameters'
require 'aadse_utilities'
require 'pp'

require 'test/unit/testcase'
require 'test/unit' if $0 == __FILE__

class TestAadseUtilities < Test::Unit::TestCase

###########################
def test_parameters_methods

parameters_root = Pathname.new(ENV['AADSE_ROOT']) + 'test' + 'data' + 'S_Generator'

parm_files = find_parameters parameters_root

#parm_files << parameters_root + "error.txt"
#pp parm_files

assert_equal 16, parm_files.length, "ERROR: Expected 16 parameters not #{parm_files.length}"

parm_files.each do |pf|
  assert_equal 'parameters', pf.basename.to_s, "ERROR: Oh No! A bad filename was included: #{pf}"
end



########################################################################
## Now test the Parameters class and the parameters_filename_mojo method

parameters  = Array.new
error_cnt   = 0
catch_cnt   = 0

parm_files.each do |pfn|

  begin
    a_parm_set = Parameters.new(pfn)
    assert true
  rescue RuntimeError => e
    puts "\nERRPR: #{e}"                if $verbose
    puts "\ton pathname: #{pfn}"        if $verbose
    error_cnt += 1
    assert false, "ERRPR: #{e}"
    next
  end

  begin
    parameters_filename_mojo(a_parm_set)
  rescue RuntimeError => e
    puts "\n#{e}"                       if $verbose
    puts "\ton pathname: #{pfn}"        if $verbose
    catch_cnt += 1
    next  
  end
  
  if $verbose
    puts "\n#{pfn}"
    puts "\tForce:    #{a_parm_set.force_designation_}"
    puts "\tCategory: #{a_parm_set.weapon_category_}"
  end
  
  parameters << a_parm_set
  
end


assert_equal 0, error_cnt,          "ERROR: All filenames should have been good."
assert_equal 6, catch_cnt,          "ERROR: Wrong catch_cnt.  Expected: 8 Got; #{catch_cnt}"
assert_equal 10, parameters.length,  "ERROR: Wrong good_parms_cnt.  Expected: 8 Got; #{parameters.length}"


end ## end of def test_parameters_methods

end ## end of class TestAadseUtilities


