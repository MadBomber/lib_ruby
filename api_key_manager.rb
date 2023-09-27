# ~/lib/ruby/api_key_manager.rb
#
# encoding: utf-8
# frozen_string_literal: true
# warn_indent: true
##########################################################
###
##  File: api_key_manager.rb
##  Desc: Manage multiple API keys based upon rate count limitation.
##  By:   Dewayne VanHoozer (dvanhoozer@gmail.com)
#
#
# Some APIs offer a free api_key with a rate limits which are too low for
# normal software development.  If you have several of these free rate limited
# keys you may be able to rotate the key usage during development.  Once your
# product reaches productions, you should ditch the free api keys are purchase
# a production key that has the appropriate characteristics your product needs.

module ApiKeyManager

  ########################################################
  # Dealing with a limitation in the API keys of a maximum
  # number of accesses per a specific period of time - usually
  # expressed as a count per X seconds.  Example: 5/60
  #
  # When the count has been used within the specified period of time,
  # then it is time to use a new API key.
  #
  # Sometimes rate limited APIs are triggered on
  # the incoming IP Address as well as the API Key.
  # In that case, when the counter runs out but there
  # is still time in the period, we have to wait
  # for the period to run out.
  #
  # TODO: need to handle multiple AND-related rate limitations
  #       for example:
  #         5 per minute    # short term
  #           AND
  #         100 per day     # long term
  #
  class Rate

    # api_keys (Array of String) or CSV String
    #   of rate limited API Keys.
    #
    # delay (Boolean) sleep when there is time
    #   left in the period but the counter has run out
    #
    # rate_count (Integer) or String convertable to Integer
    #   number of times to use an API Key before
    #   changing to a new one.
    #
    # rate_period (Integer) or String convertable to Integer
    #   number of seconds to use an API Key before
    #   changing to a new one.
    #
    def initialize(
        api_keys:,
        delay:      false,
        rate_count:   5,
        rate_period: 60
      )
      @api_keys       = api_keys.is_a?(String)  ? api_keys.split(',') : api_keys

      @delay          = delay

      @rate_count     = rate_count.is_a?(String)  ? rate_count.to_i   : rate_count
      @rate_period    = rate_period.is_a?(String) ? rate_period.to_i  : rate_period

      @start_timer  = Time.now.to_i
      @end_timer    = @start_timer - 1 # prevent delay

      reset_counter

      @current_index  = 0
    end


    def reset_counter
      @counter  = @rate_count
    end


    def reset_timer
      now = Time.now.to_i

      if @delay && now < @end_timer
        delta = @end_timer - now + 2 # MAGIC: 2 is a WAG fudge factor
        sleep(delta) # FIxME: This stops everything; need an async solution
        now = Time.now.to_i
      end

      @start_timer  = now
      @end_timer    = @start_timer + @rate_period
    end


    # Returns the api_key to use for the current access.
    #
    def api_key
      now = Time.now.to_i

      # Have we already used up our access count for this period?
      if now <= @end_timer && @counter < 1
        @current_index  = (@current_index + 1) % @api_keys.length
        reset_timer
        reset_counter
      elsif now > @end_timer
        # Continue using same api key
        reset_timer
        reset_counter
      end

      # SNELL: Can counter go negative?  If so, do we care?

      @counter -= 1
      @api_keys[@current_index]
    end
    alias_method :key, :api_key
  end # class Rate
end # module ApiKeyManager
