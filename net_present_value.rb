~/lib/ruby/net_present_value.rb

# Calculates the Net Present Value (NPV) of a series of cash flows
# using an array of time-period-specific interest rates.
#
# NPV is a financial metric used to assess the profitability of an
# investment or project. It compares the present value of all
# future cash inflows to the present value of all cash outflows.
#
# In the cash_flows array:
# - Positive values represent cash inflows (e.g., revenue)
# - Negative values represent cash outflows (e.g., costs)
#
# The first element in the cash_flows array typically represents
# the initial investment (usually a negative value).
#
# @param cash_flows [Array<Float>] Array of future cash
#   inflows/outflows at each time period
# @param interest_rates [Array<Float>] Array of interest rates for
#   each time period
# @return [Float] The calculated Net Present Value
def net_present_value(cash_flows:, interest_rates:)
  # Validate input lengths
  if cash_flows.length != interest_rates.length
    raise ArgumentError, "Cash flows and interest rates must be same length"
  end

  cash_flows.map.with_index do |cash_flow, time_period|
    cash_flow / (1 + interest_rates[time_period]) ** time_period.to_f
  end.sum
end

# Example usage:

# Scenario 1: Evaluating a business investment
initial_investment = -1000.0
year1_cash_flow    =   300.0
year2_cash_flow    =   400.0
year3_cash_flow    =   500.0

cash_flows     = [initial_investment, year1_cash_flow, year2_cash_flow, year3_cash_flow]
interest_rates = [0.05, 0.05, 0.06, 0.06]

npv = net_present_value(cash_flows: cash_flows, interest_rates: interest_rates)
puts "Investment NPV: $#{npv.round(2)}"

# Scenario 2: Comparing two project options
project_a_cash_flows = [-5000, 1500, 2000, 2500]
project_b_cash_flows = [-4000, 1000, 1500, 2000]
interest_rates       = [0.08, 0.08, 0.08, 0.08]

npv_a = net_present_value(cash_flows: project_a_cash_flows, interest_rates: interest_rates)
npv_b = net_present_value(cash_flows: project_b_cash_flows, interest_rates: interest_rates)

puts "Project A NPV: $#{npv_a.round(2)}"
puts "Project B NPV: $#{npv_b.round(2)}"
puts "Choose #{npv_a > npv_b ? 'Project A' : 'Project B'}"

__END__

This expanded version includes:

1. More detailed comments explaining the concept of NPV and how the `cash_flows` array is structured.
2. Updated method signature using named parameters for better readability.
3. Two example scenarios demonstrating how NPV can be used in real-world situations:

   - Scenario 1: Evaluating a single business investment over three years.
   - Scenario 2: Comparing two different project options to decide which one is more financially viable.

These examples show how NPV can be used to:

1. Determine if a single investment is profitable (positive NPV indicates profitability).
2. Compare multiple investment options to choose the most financially beneficial one.
3. Account for varying interest rates over different time periods.

NPV is widely used in finance and business for capital budgeting, investment analysis, and project evaluation. It helps decision-makers assess the long-term value of investments while considering the time value of money.
