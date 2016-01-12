###############################################################
###
##  File: system_package.rb
##  Adds some system package capability to the Gemfile
#

if defined? $TDV_PASS
  $TDV_PASS += 1
else
  $TDV_PASS = 1
end

def fedora?() 'Fedora'==ENV['_system_name'];end
def mac?()    'OSX'   ==ENV['_system_name'];end

if fedora?
  $lib_install_command = 'sudo yum -y install $@ 2>&1'
  $lib_check_command   = 'yum list installed  $@ 2>&1'
elsif mac?
  $lib_install_command = 'brew install $@ 2>&1'
  $lib_check_command   = 'brew ls --versions $@ 2>&1'
else
  puts "UNKNOWN SYSTEM NAME: #{ENV['_system_name']}"
  $lib_install_command = 'echo ERROR processing $@ 2>&1'
  $lib_check_command   = 'echo ERROR processing $@ 2>&1'
end

def system_package(a_string)
  case $TDV_PASS
  when 1
    unless defined?($TDV_SYSLIB_ARRAY)
      $TDV_SYSLIB_ARRAY = Array.new
    end
    unless $TDV_SYSLIB_ARRAY.include? a_string
      result = `#{$lib_check_command.gsub('$@',a_string)}`
      $TDV_SYSLIB_ARRAY << a_string unless result.include?(a_string)
    end
  when 2
    if $TDV_SYSLIB_ARRAY.include? a_string
      puts "Installing system lib/pgm dependency: #{a_string}"
      result = `#{$lib_install_command.gsub('$@',a_string)}`
      puts result
      $TDV_SYSLIB_ARRAY.delete a_string
    else
      puts "Using system lib/pgm dependency #{a_string}"
    end
  else
    puts "============= ERROR: what? pass number is #{$TDV_PASS}"
  end
end # def system_package(a_string)

