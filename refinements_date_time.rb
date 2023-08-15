##############################################
###
##  File: refinements_date_time.rb
##  Desc:  Refinements to the Date, DateTime and Time classes.
#

module Refinements
  module ModsDataTimeEtc
    def before?(thing) (self <= thing); end
    def after?(thing)  (self >= thing); end
  end

  refine ::Date do
    include ModsDateTimeEtc
    def to_unix() self.to_time.to_i; end
  end

  refine ::DateTime do
    include ModsDateTimeEtc
    def to_unix() self.to_time.to_i; end
  end

  refine ::Time do
    include ModsDateTimeEtc
    def to_unix() self.to_i; end
  end
end # module Refinements
