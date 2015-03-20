#####################################
###
##  File: random_an.rb
##  Desc: Random Alpha-numberic stings
#

module RandomAN
  CHARSET = [*'a'..'z', *'A'..'Z', *'0'..'9']
  def random_an(number)
    CHARSET.sample(number).join
  end
end # module RandomAN
