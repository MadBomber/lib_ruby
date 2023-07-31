# lib/ruby/fin_tech.rb

# FinTech - Financial Technology
# Quantity Analysis??


class FinTech
  class << self

    #######################################################################
    # Moving Averages - Simple Moving Average (SMA)
    #
    # This method takes in an array of historical prices for a stock and a 
    # period (the number of days to calculate the moving average over). It 
    # uses the `each_cons` method to iterate over a sliding window of closing 
    # prices and calculate the moving average for each window. The method 
    # returns an array of the moving averages for each window.

    def moving_averages(data, period)
      if data.first.is_a? Hash
        prices = data.map{|r| r['Adj Close'].to_f}
      else
        prices = data 
      end

      moving_averages = []
      prices.each_cons(period) do |window|
        moving_average = window.sum / period.to_f
        moving_averages << moving_average
      end
      return moving_averages
    end
    alias_method :sma, :moving_averages


    # Simple Moving Average Trend - up or down with angle
    #
    def sma_trend(data, period)
      closes    = data.map{|r| r['Adj Close'].to_f}
      sma       = moving_averages(closes, period)
      last_sma  = sma.last
      prev_sma  = sma[-2]
      angle     = Math.atan((last_sma - prev_sma) / period) * (180 / Math::PI)
      
      if last_sma > prev_sma
        trend = 'up'
      else
        trend = 'down'
      end

      { trend: trend, angle: angle }
    end


    #######################################################################
    # Relative Strength Index (RSI)
    #
    # This method takes in an array of historical prices for a stock and a 
    # period (the number of days to calculate the RSI over). It uses 
    # the `each_cons` method to iterate over a sliding window of closing 
    # prices and calculate the gains and losses for each window. Then, it 
    # calculates the average gain and average loss for the time period and 
    # uses these values to calculate the RSI. The method returns the RSI 
    # value for the given period.
    #
    #   over_bought if rsi >= 70
    #   over_sold   if rsi <= 30

    def rsi(data, period)
      prices  = data.map{|r| r['Adj Close'].to_f}
      gains   = []
      losses  = []

      prices.each_cons(2) do |pair|
        change = pair[1] - pair[0]
        if change > 0
          gains   << change
          losses  << 0
        else
          gains   << 0
          losses  << -change
        end
      end

      avg_gain  = gains.first(period).sum / period.to_f
      avg_loss  = losses.first(period).sum / period.to_f
      rs        = avg_gain / avg_loss
      rsi       = 100 - (100 / (1 + rs))

      meaning = ""
      if rsi >= 70.0
        meaning = "Over Bought"
      elsif rsi <= 30.0
        meaning = "Over Sold"
      end

      return {rsi: rsi, meaning: meaning}
    end


    #######################################################################
    # Bollinger Bands
    #
    # This method takes in an array of historical prices for a stock, a 
    # period (the number of days to calculate the moving average and standard 
    # deviation over), and the number of standard deviations to use for the 
    # upper and lower Bollinger Bands. It uses the `moving_averages` method to 
    # calculate the moving average for the given period, and then calculates the 
    # standard deviation of the closing prices for each window of the given period. 
    # Finally, it calculates the upper and lower Bollinger Bands based on the moving 
    # average and standard deviation, and returns an array containing the upper and 
    # lower bands.
    #
    # The `num_std_dev` parameter in the Bollinger Bands method specifies the number
    # of standard deviations to use for the upper and lower bands. The default
    # value for this parameter can depend on the specific security being analyzed
    # and the time period being used.
    #
    # A common default value for `num_std_dev` is 2, which corresponds to the
    # standard deviation of the price data over the given time period. Using a
    # value of 2 for `num_std_dev` will result in the upper and lower bands being
    # placed at a distance of two standard deviations from the moving average.
    #
    # However, the optimal value for `num_std_dev` can vary depending on the
    # volatility of the security being analyzed. For highly volatile securities, a
    # larger value for `num_std_dev` may be more appropriate, while for less
    # volatile securities, a smaller value may be more appropriate.
    #
    # Ultimately, the best default value for `num_std_dev` will depend on the
    # specific use case and should be chosen based on the characteristics of the
    # security being analyzed and the preferences of the analyst.
    #
    # The difference between the upper and lower bands can
    # be an indicator of how volatile the stock is.

    def bollinger_bands(data, period, num_std_devs=2)
      prices              = data.map{|r| r['Adj Close'].to_f}
      moving_averages     = moving_averages(data, period)
      standard_deviations = []

      prices.each_cons(period) do |window|
        standard_deviation = Math.sqrt(window.map { |price| (price - moving_averages.last) ** 2 }.sum / period)
        standard_deviations << standard_deviation
      end

      upper_band = moving_averages.last + (num_std_devs * standard_deviations.last)
      lower_band = moving_averages.last - (num_std_devs * standard_deviations.last)
      
      return [upper_band, lower_band]
    end


    #######################################################################
    # Moving Average Convergence Divergence (MACD)
    # 

    # The MACD is a trend-following momentum indicator that measures the
    # relationship between two moving averages over a specified time period. The
    # MACD is calculated by subtracting the long-term moving average from the
    # short-term moving average.
    #
    # The method takes in an array of historical prices for a stock, a short period
    # (the number of days to calculate the short-term moving average over), a long
    # period (the number of days to calculate the long-term moving average over),
    # and a signal period (the number of days to calculate the signal line moving
    # average over).
    #
    # The method first calculates the short-term moving average by calling the
    # `moving_averages` method with the `prices` array and the `short_period`
    # parameter. It then calculates the long-term moving average by calling the
    # `moving_averages` method with the `prices` array and the `long_period`
    # parameter.
    #
    # Next, the method calculates the MACD line by subtracting the long-term moving
    # average from the short-term moving average. This is done by taking the last
    # element of the `short_ma` array (which contains the short-term moving
    # averages for each window) and subtracting the last element of the `long_ma`
    # array (which contains the long-term moving averages for each window).
    #
    # Finally, the method calculates the signal line by taking the moving average of
    # the MACD line over the specified `signal_period`. This is done by calling the
    # `moving_averages` method with the `short_ma` array and the `signal_period`
    # parameter, and taking the last element of the resulting array.
    #
    # The method returns an array containing the MACD line and the signal line.
    #
    # Note that this is just a basic implementation of the MACD indicator, and there
    # are many variations and refinements that can be made depending on the
    # specific requirements of your program.
    #
    # The Moving Average Convergence Divergence (MACD) is a technical analysis
    # indicator that is used to identify changes in momentum, direction, and trend
    # for a security. The MACD is calculated by subtracting the 26-period
    # exponential moving average (EMA) from the 12-period EMA.
    #
    # The values 1.8231937142857078 and 164.44427957142855 that you provided are
    # likely the MACD line and the signal line, respectively. The MACD line is the
    # difference between the 12-period EMA and the 26-period EMA, while the signal
    # line is a 9-period EMA of the MACD line.
    #
    # The MACD line crossing above the signal line is often considered a bullish
    # signal, while the MACD line crossing below the signal line is often
    # considered a bearish signal. The distance between the MACD line and the
    # signal line can also provide insight into the strength of the trend.
    #
    # Without additional context, it's difficult to interpret the specific values of
    # 1.8231937142857078 and 164.44427957142855 for the MACD and signal lines of a
    # stock. However, in general, the MACD can be used to identify potential buy
    # and sell signals for a security, as well as to provide insight into the
    # strength of the trend.

    def macd(data, short_period, long_period, signal_period)
      short_ma    = moving_averages(data, short_period)
      long_ma     = moving_averages(data, long_period)
      macd_line   = short_ma.last - long_ma.last
      signal_line = moving_averages(short_ma, signal_period).last
      
      return [macd_line, signal_line]
    end


    # Calculates the Donchian Channel for a given period and input data.
    #
    # In the domain of computer programming, a Donchian Channel is a technical 
    # analysis indicator used to identify potential breakouts and trend reversals 
    # in financial markets. It consists of three lines: the upper channel line, 
    # the lower channel line, and the middle line.
    #
    # The upper channel line is calculated by finding the highest high over 
    # a specified period of time, while the lower channel line is calculated 
    # by finding the lowest low over the same period. The middle line is simply 
    # the average of the upper and lower channel lines.
    #
    # @param period [Integer] The period for the Donchian Channel.
    # @param input_data [Array] An array of values.
    # @return [Array] An array of arrays representing the Donchian Channel.
    #
    def donchian_channel(period, input_data)
      max = -999999999
      min = 999999999
      donchian_channel = []

      input_data.each_with_index do |value, index|
        value = value.to_f
        max = value if value > max
        min = value if value < min

        if index >= period - 1
          donchian_channel << [max, min, (max + min) / 2]
          max = -999999999
          min = 999999999
        end
      end

      donchian_channel
    end


    # Calculates the True Range (TR) for a given set of price data.
    #
    # The True Range is a measure of the price volatility of a security over a given
    # period.  It is calculated as the greatest of the following three values:
    # - The difference between the current high and the current low.
    # - The absolute value of the difference between the current high and the previous 
    #   close.
    # - The absolute value of the difference between the current low and the previous 
    #   close.
    #
    # The True Range helps to capture the true extent of price movement, taking 
    # into account potential gaps or price jumps between periods. It is often used 
    # as a component in calculating other indicators, such as the Average True Range.
    #
    # @param high_prices [Array] An array of high prices.
    # @param low_prices [Array] An array of low prices.
    # @param previous_closes [Array] An array of previous closing prices.
    # @return [Array] An array of True Range values.
    #
    def true_range(high_prices, low_prices, previous_closes)
      true_ranges = []

      high_prices.each_with_index do |high, index|
        low = low_prices[index]
        previous_close = previous_closes[index]

        true_range = [
          high - low,
          (high - previous_close).abs,
          (low - previous_close).abs
        ].max

        true_ranges << true_range
      end

      true_ranges
    end
    alias_method :tr, :true_range


    # Calculates the Average True Range (ATR) for a given set of price data.
    #
    # The Average True Range is an indicator that calculates the average of the 
    # True Range values over a specified period. It provides a measure of the 
    # average volatility of a security over that period.
    #
    # The ATR is commonly used to assess the volatility of a security, identify 
    # potential trend reversals, and determine appropriate stop-loss levels. Higher 
    # ATR values indicate higher volatility, while lower ATR values indicate lower 
    # volatility.
    #
    # For example, a 14-day Average True Range would calculate the average of the 
    # True Range values over the past 14 trading days. Traders and analysts may
    # use this indicator to set stop-loss levels based on the average volatility 
    # of the security.
    #
    # @param high_prices [Array] An array of high prices.
    # @param low_prices [Array] An array of low prices.
    # @param close_prices [Array] An array of closing prices.
    # @param period [Integer] The period for calculating the ATR.
    # @return [Array] An array of Average True Range values.
    #
    def average_true_range(high_prices, low_prices, close_prices, period)
      true_ranges = calculate_true_range(high_prices, low_prices, close_prices)
      atr_values = []

      true_ranges.each_with_index do |true_range, index|
        if index < period - 1
          atr_values << nil
        elsif index == period - 1
          atr_values << true_ranges[0..index].sum / period.to_f
        else
          atr_values << (atr_values[index - 1] * (period - 1) + true_range) / period.to_f
        end
      end

      atr_values
    end
    alias_method :atr, :average_true_range


  end
end

