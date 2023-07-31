# lib/ruby/fin_tech.rb

# FinTech - Financial Technology
# A collection of class methods to support Quantity Analysis


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


    #######################################################################
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


    #######################################################################
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


    #######################################################################
    # Calculates the Stochastic Oscillator for a given set of price data.
    #
    # Stochastic Oscillator: The Stochastic Oscillator compares a security's 
    # closing price to its price range over a specified period. It helps 
    # identify potential trend reversals and overbought/oversold conditions.
    #
    # @param high_prices [Array] An array of high prices.
    # @param low_prices [Array] An array of low prices.
    # @param close_prices [Array] An array of closing prices.
    # @param period [Integer] The period for calculating the Stochastic Oscillator.
    # @param smoothing_period [Integer] The smoothing period for %K line.
    # @return [Array] An array of %K and %D values.
    #
    def stochastic_oscillator(high_prices, low_prices, close_prices, period, smoothing_period)
      k_values = []
      d_values = []

      close_prices.each_cons(period) do |closing_prices|
        highest_high = high_prices.max(period)
        lowest_low = low_prices.min(period)

        current_close = closing_prices.last
        k_value = (current_close - lowest_low) / (highest_high - lowest_low) * 100
        k_values << k_value
      end

      k_values.each_cons(smoothing_period) do |k_values_subset|
        d_value = k_values_subset.sum / smoothing_period.to_f
        d_values << d_value
      end

      [k_values, d_values]
    end


    #######################################################################
    # Calculates the Fibonacci Retracement levels for a given price range.
    #
    # Fibonacci Retracement: Fibonacci retracement uses Fibonacci ratios to 
    # identify potential support and resistance levels based on the price's 
    # previous significant moves.
    #
    # @param start_price [Float] The starting price of the range.
    # @param end_price [Float] The ending price of the range.
    # @return [Array] An array of Fibonacci Retracement levels.
    #
    def fibonacci_retracement(start_price, end_price)
      retracement_levels = []

      retracement_levels << end_price
      retracement_levels << start_price

      fibonacci_levels = [0.236, 0.382, 0.5, 0.618, 0.786]

      fibonacci_levels.each do |level|
        retracement = start_price + (end_price - start_price) * level
        retracement_levels << retracement
      end

      retracement_levels
    end


    #######################################################################
    # Pattern Recognition: Pattern recognition techniques, such as chart 
    # patterns (e.g., head and shoulders, double top/bottom) and candlestick 
    # patterns, are used to identify potential trend reversals and continuation 
    # patterns.


    # Checks if a "head and shoulders" pattern is present in the given price data.
    #
    # @param prices [Array] An array of price values.
    # @return [Boolean] True if the pattern is present, false otherwise.
    #
    def head_and_shoulders_pattern?(prices)
      return false if prices.length < 5

      left_shoulder = prices[0]
      head = prices[1]
      right_shoulder = prices[2]
      neckline = prices[3]
      right_peak = prices[4]

      if head > left_shoulder && head > right_shoulder && right_peak < neckline
        return true
      else
        return false
      end
    end


    # Checks if a "double top" or "double bottom" pattern is present in the 
    # given price data.
    #
    # @param prices [Array] An array of price values.
    # @return [String]  The pattern ("double top", "double bottom") if present, 
    #                   "no pattern" otherwise.
    # 
    def double_top_bottom_pattern?(prices)
      return "no pattern" if prices.length < 5

      first_peak = prices[0]
      valley = prices[1]
      second_peak = prices[2]
      neckline = prices[3]
      confirmation_price = prices[4]

      if first_peak < second_peak && valley > first_peak && valley > second_peak && confirmation_price < neckline
        return "double top"
      elsif first_peak > second_peak && valley < first_peak && valley < second_peak && confirmation_price > neckline
        return "double bottom"
      else
        return "no pattern"
      end
    end


    # Recognizes common candlestick chart patterns in the given price data.
    #
    # @param open_prices [Array] An array of opening prices.
    # @param high_prices [Array] An array of high prices.
    # @param low_prices [Array] An array of low prices.
    # @param close_prices [Array] An array of closing prices.
    # @return [Array] An array of recognized candlestick patterns.
    #
    def candlestick_pattern_recognizer(open_prices, high_prices, low_prices, close_prices)
      patterns = []

      close_prices.each_with_index do |close, index|
        if index >= 2
          previous_close = close_prices[index - 1]
          previous_open = open_prices[index - 1]
          previous_high = high_prices[index - 1]
          previous_low = low_prices[index - 1]

          second_previous_close = close_prices[index - 2]
          second_previous_open = open_prices[index - 2]
          second_previous_high = high_prices[index - 2]
          second_previous_low = low_prices[index - 2]

          if close > previous_close && previous_close < previous_open && close < previous_open && close > previous_low && close > second_previous_close
            patterns << "Bullish Engulfing"
          elsif close < previous_close && previous_close > previous_open && close > previous_open && close < previous_high && close < second_previous_close
            patterns << "Bearish Engulfing"
          elsif close > previous_close && previous_close < previous_open && close < previous_open && close < previous_low && close < second_previous_close
            patterns << "Bearish Harami"
          elsif close < previous_close && previous_close > previous_open && close > previous_open && close > previous_high && close > second_previous_close
            patterns << "Bullish Harami"
          end
        end
      end

      patterns
    end


    #######################################################################
    # Determines if a stock exhibits mean reversion behavior based on a given 
    # price series.
    #
    # Mean Reversion Strategies: Mean reversion strategies aim to capitalize on 
    # the tendency of prices to revert to their mean or average value. These 
    # strategies involve identifying overextended price movements and taking 
    # positions that anticipate a return to the mean.
    #
    # @param prices [Array] An array of historical prices.
    # @param lookback_period [Integer] The number of periods to consider for calculating the mean.
    # @param deviation_threshold [Float]  The threshold for considering a 
    #                                     price movement as overextended.  For example
    #                                     0.50 is a 50 cent (half dollar) change.
    # @return [Boolean] True if the stock exhibits mean reversion behavior, 
    #                   false otherwise.
    #
    def mean_reversion?(prices, lookback_period, deviation_threshold)
      return false if prices.length < lookback_period

      mean      = mr_mean(prices, lookback_period)
      deviation = prices[-1] - mean

      if deviation.abs > deviation_threshold
        return true
      else
        return false
      end
    end


    def mr_mean(prices, lookback_period)
      prices[-lookback_period..-1].sum / lookback_period.to_f
    end



    #######################################################################
    # Wave Theory: Wave theory, such as Elliott Wave Theory, suggests that 
    # price movements follow repetitive patterns or waves. It aims to identify 
    # and predict these patterns to make trading decisions.
    #
    # Identifies a wave condition in a stock's price history based on a given 
    # price series.
    #
    # @param prices [Array] An array of historical prices.
    # @param wave_length [Integer] The expected length of a wave pattern.
    # @param tolerance [Float]  The tolerance level for considering a price movement 
    #                           as part of a wave.
    # @return [Boolean] True if a wave condition is identified, false otherwise.
    #
    def identify_wave_condition?(prices, wave_length, tolerance)
      return false if prices.length < wave_length

      wave_start = 0
      wave_end = wave_length - 1

      while wave_end < prices.length
        wave = prices[wave_start..wave_end]

        if wave.length == wave_length && wave_pattern?(wave, tolerance)
          return true
        end

        wave_start += 1
        wave_end += 1
      end

      false
    end

    # Checks if a given wave pattern satisfies the wave condition based on a 
    # tolerance level.
    #
    # @param wave [Array] An array representing a wave pattern.
    # @param tolerance [Float]  The tolerance level for considering a price movement 
    #                           as part of a wave.
    # @return [Boolean] True if the wave pattern satisfies the wave condition, 
    #                   false otherwise.
    #
    def wave_pattern?(wave, tolerance)
      wave.each_cons(2) do |a, b|
        return false if (b - a).abs > tolerance
      end

      true
    end


    #######################################################################
    # Classifies the market profile based on trading volume and price levels.
    #
    # Market Profile Analysis: Market profile analysis involves studying the 
    # distribution of trading volume and price levels over time. It helps 
    # identify areas of support and resistance and provides insights into market 
    # sentiment.
    #
    # @param volume [Array] An array of trading volume data.
    # @param prices [Array] An array of price levels.
    # @param support_threshold [Float]  The threshold for considering a price level 
    #                                   as support.
    # @param resistance_threshold [Float] The threshold for considering a price 
    #                                     level as resistance.
    # @return [String] The classification of the market profile.
    #
    def classify_market_profile(volume, prices, support_threshold, resistance_threshold)
      return "Insufficient data" if volume.empty? || prices.empty?

      total_volume    = volume.sum
      average_volume  = total_volume / volume.length.to_f
      max_volume      = volume.max

      support_levels    = prices.select { |price| price <= support_threshold }
      resistance_levels = prices.select { |price| price >= resistance_threshold }

      if support_levels.empty? && resistance_levels.empty?
        return "Neutral"
      elsif support_levels.empty?
        return "Resistance"
      elsif resistance_levels.empty?
        return "Support"
      else
        return "Mixed"
      end
    end


    #######################################################################
    # Calculates the momentum of a stock based on the rate of change (ROC).
    #
    # The interpretation of a stock's momentum value in terms of forecasting future 
    # price depends on the specific trading strategy or approach being used. However, 
    # in general, a positive momentum value indicates that the stock's price has been 
    # increasing over the specified period, while a negative momentum value indicates 
    # that the stock's price has been decreasing.
    # 
    # Here are some common interpretations of momentum values:
    # 
    # 1. Positive Momentum: A positive momentum value suggests that the stock's 
    # price has been trending upwards. This could indicate that the stock is in 
    # an uptrend and may continue to rise in the near future. Traders and investors 
    # may interpret this as a bullish signal and consider buying or holding the 
    # stock.
    #
    # 2. Negative Momentum: A negative momentum value suggests that the stock's 
    # price has been trending downwards. This could indicate that the stock is 
    # in a downtrend and may continue to decline in the near future. Traders and 
    # investors may interpret this as a bearish signal and consider selling or 
    # avoiding the stock.
    #
    # 3. High Momentum: A high positive momentum value indicates a strong upward 
    # trend in the stock's price. This could suggest that the stock has significant 
    # buying pressure and may continue to rise. Traders and investors may interpret 
    # this as a strong bullish signal and consider entering or adding to their 
    # positions.
    #
    # 4. Low Momentum: A low positive momentum value suggests a weak upward trend 
    # or a sideways movement in the stock's price. This could indicate a lack of 
    # significant buying pressure. Traders and investors may interpret this as a 
    # neutral signal and may choose to wait for a stronger momentum signal or look 
    # for other indicators to make trading decisions.
    # 
    # It's important to note that momentum alone may not be sufficient for 
    # accurate price forecasting. It is often used in conjunction with other 
    # technical indicators, fundamental analysis, or market conditions to make 
    # more informed trading decisions.
    #
    # Additionally, the interpretation of momentum values may vary depending on 
    # the time frame and the specific trading strategy being employed. Traders and 
    # investors should consider their own risk tolerance, investment goals, and 
    # trading approach when interpreting momentum values for forecasting future 
    # price movements.
    #
    #
    # @param prices [Array] An array of historical prices.
    # @param period [Integer] The number of periods to consider for calculating the ROC.
    # @return [Float] The momentum of the stock.
    #
    def momentum(prices, period)
      return 0.0 if prices.length <= period

      current_price = prices[-1]
      past_price = prices[-(period + 1)]

      roc = (current_price - past_price) / past_price.to_f
      momentum = roc * 100.0

      momentum
    end


    ##############################################################################
    # Calculates the Exponential Moving Average (EMA) and performs basic analysis.
    #
    # In financial analysis, the Exponential Moving Average (EMA) is a commonly used 
    # technical indicator that helps identify trends and smooth out price data. It is 
    # a type of moving average that gives more weight to recent prices, making it more
    #  responsive to recent price changes compared to other moving averages.
    #
    # The EMA is calculated by applying a smoothing factor (often represented as a 
    # percentage) to the previous EMA value and adding a weighted average of the 
    # current price. The smoothing factor determines the weight given to the most 
    # recent price data, with higher values giving more weight to recent prices.
    #
    # The EMA is used for various purposes in financial analysis, including:
    #
    # 1. Trend Identification: The EMA is often used to identify the direction and 
    # strength of a trend. When the current price is above the EMA, it suggests an 
    # uptrend, while a price below the EMA suggests a downtrend. Traders and 
    # investors may use the EMA crossover (when the price crosses above or below
    # the EMA) as a signal to enter or exit positions.
    #
    # 2. Support and Resistance Levels: The EMA can act as dynamic support or 
    # resistance levels. In an uptrend, the EMA may provide support, and in a 
    # downtrend, it may act as resistance. Traders may use the EMA as a reference 
    # point for setting stop-loss orders or profit targets.
    #
    # 3. Price Reversals: The EMA can help identify potential price reversals. When 
    # the price deviates significantly from the EMA, it may indicate an overbought 
    # or oversold condition, suggesting a potential reversal in the near future. 
    # Traders may use this information to anticipate price reversals and adjust 
    # their trading strategies accordingly.
    #
    # 4. Volatility Assessment: The EMA can be used to assess market volatility. 
    # When the EMA is relatively flat, it suggests low volatility, while a steeply 
    # sloping EMA indicates higher volatility. Traders may adjust their trading 
    # strategies based on the level of volatility indicated by the EMA.
    #
    # It's important to note that the EMA is just one of many technical indicators 
    # used in financial analysis. It is often used in combination with other 
    # indicators, such as the Simple Moving Average (SMA), to gain a more 
    # comprehensive understanding of market trends and price movements.
    # 
    # Traders and investors should consider their own trading strategies, risk 
    # tolerance, and timeframes when using the EMA or any other technical indicator 
    # for financial analysis. It's also recommended to backtest and validate any 
    # trading strategies before applying them in real-time trading.
    #
    #
    # @param prices [Array] An array of historical prices.
    # @param period [Integer] The number of periods to consider for calculating 
    #                         the EMA.
    # @return [Hash] A hash containing the EMA values and analysis results.
    #
    def ema_analysis(prices, period)
      return {} if prices.empty? || period <= 0

      ema_values = []
      ema_values << prices.first

      multiplier = (2.0 / (period + 1))

      (1...prices.length).each do |i|
        ema = (prices[i] - ema_values.last) * multiplier + ema_values.last
        ema_values << ema.round(2)
      end

      analysis = {}

      analysis[:ema_values] = ema_values
      analysis[:trend]      = determine_trend(ema_values)
      analysis[:support]    = determine_support(ema_values)
      analysis[:resistance] = determine_resistance(ema_values)

      analysis
    end

    # Determines the trend based on the EMA values.
    #
    # @param ema_values [Array] An array of EMA values.
    # @return [Symbol] The trend: :up, :down, or :sideways.
    #
    def determine_trend(ema_values)
      return :sideways if ema_values.empty?

      last_ema      = ema_values.last
      previous_ema  = ema_values[-2]

      if last_ema > previous_ema
        :up
      elsif last_ema < previous_ema
        :down
      else
        :sideways
      end
    end

    # Determines the support level based on the EMA values.
    #
    # @param ema_values [Array] An array of EMA values.
    # @return [Float] The support level.
    #
    def determine_support(ema_values)
      return 0.0 if ema_values.empty?

      ema_values.min
    end

    # Determines the resistance level based on the EMA values.
    #
    # @param ema_values [Array] An array of EMA values.
    # @return [Float] The resistance level.
    def determine_resistance(ema_values)
      return 0.0 if ema_values.empty?

      ema_values.max
    end
  end
end


__END__

Here are a few other things to consider ....


Volatility Indicators: Volatility indicators, such as Average True Range (ATR) and Standard Deviation, help measure the degree of price fluctuations and assess market volatility.

Correlation Analysis: Correlation analysis measures the relationship between two or more securities or assets. It helps identify diversification opportunities and assess portfolio risk.

Regression Analysis: Regression analysis is used to model and analyze the relationship between a dependent variable (e.g., stock price) and one or more independent variables (e.g., market index).

Volume Analysis: Volume analysis examines the trading volume of a security to identify patterns and trends. It helps assess the strength of price movements and potential market reversals.

Oscillators: Oscillators, such as the Commodity Channel Index (CCI) and the Williams %R, are used to identify overbought and oversold conditions and potential trend reversals.

Market Breadth Indicators: Market breadth indicators, such as the Advance-Decline Line and the McClellan Oscillator, measure the overall health of the market by analyzing the number of advancing and declining stocks.

# Calculates the Advance-Decline Line (ADL) for a given array of advancing and declining values.
#
# @param advancing_values [Array] An array of advancing values.
# @param declining_values [Array] An array of declining values.
# @return [Array] An array representing the Advance-Decline Line.
#
def advance_decline_line(advancing_values, declining_values)
  adl = []
  advancing_sum = 0
  declining_sum = 0

  advancing_values.each_with_index do |advancing, index|
    declining = declining_values[index]
    advancing_sum += advancing
    declining_sum += declining
    adl << advancing_sum - declining_sum
  end

  adl
end


# Calculates the McClellan Oscillator for a given array of advancing and declining values.
#
# @param advancing_values [Array] An array of advancing values.
# @param declining_values [Array] An array of declining values.
# @param ema_period [Integer] The period for calculating the exponential moving average (EMA).
# @return [Array] An array representing the McClellan Oscillator.
#
def mcclellan_oscillator(advancing_values, declining_values, ema_period)
  adl = calculate_advance_decline_line(advancing_values, declining_values)
  ema = calculate_exponential_moving_average(adl, ema_period)
  oscillator = []

  adl.each_with_index do |adl_value, index|
    oscillator << adl_value - ema[index]
  end

  oscillator
end



Statistical Arbitrage: Statistical arbitrage involves identifying and exploiting pricing inefficiencies between related securities based on statistical models and analysis.

Event-Driven Analysis: Event-driven analysis involves analyzing the impact of specific events, such as earnings announcements, economic data releases, or news events, on the price and volatility of securities.

Sentiment Analysis: Sentiment analysis involves analyzing social media, news sentiment, and other sources of market sentiment to gauge investor sentiment and potential market movements.

Risk Management Models: Risk management models, such as Value at Risk (VaR) and Conditional Value at Risk (CVaR), are used to assess and manage portfolio risk.

Time Series Analysis: Time series analysis techniques, such as autoregressive integrated moving average (ARIMA) models and GARCH models, are used to forecast future price movements based on historical data patterns. ## TODO: translate the java libraries for ARIMA and GARCH into Ruby.


High-Frequency Trading (HFT) Algorithms: High-frequency trading algorithms use complex quantitative models and algorithms to execute trades at high speeds and take advantage of short-term market inefficiencies.

Neural Networks: Neural networks are a type of machine learning model that can be used to analyze financial data and make predictions. They are capable of learning complex patterns and relationships in the data.

Genetic Algorithms: Genetic algorithms are optimization techniques inspired by the process of natural selection. They can be used to optimize trading strategies by evolving and selecting the best-performing strategies over time.

Market Microstructure Analysis: Market microstructure analysis focuses on the dynamics and structure of financial markets, including order flow, liquidity, and price impact. It helps understand the behavior of market participants and their impact on prices.

Pair Trading: Pair trading involves identifying two related securities and taking long and short positions simultaneously to profit from the relative price movements between the two securities. It aims to capture market-neutral returns.

Monte Carlo Simulation: Monte Carlo simulation involves using random sampling techniques to model and simulate potential future price movements. It helps assess the risk and uncertainty associated with investment decisions.

Quantitative Factor Models: Quantitative factor models use statistical techniques to identify and analyze factors that drive asset returns. These models help construct portfolios based on factors such as value, momentum, and quality.

Text Mining and Natural Language Processing: Text mining and natural language processing techniques are used to analyze textual data, such as news articles and social media sentiment, to gain insights into market trends and sentiment.


