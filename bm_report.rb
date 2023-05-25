# ~/lib/ruby/bm_report.rb

# Print a pretty benchmark report
#
# results is an Array of test_case benchmarks
# 
# When there 2 test_cases, calculates the
# % change in performance of the first test_case
# over the 2nd (last) test_case.
#
def bm_report(results)
  test_cases = results.size

  # labels is the first column in the
  # report table.  it is the names of the
  # benchmark attributes.
  #
  labels = %w[
    label
    cstime
    cutime
    stime
    utime
    real 
    total
  ]

  headers = ['Label']
  data    = []

  labels.each do |label|
    if "label" == label 
      results.each do |r|
        headers << r.send(label)
      end
      
      headers << "Calc %" if 2 == test_cases
      next
    end

    row = [label]

    results.each do |r|
      row << r.send(label).round(5)
    end

    if 2 == test_cases
      row << (results.first.send(label) / results.last.send(label) * 100.0).round(5)
    end

    data << row
  end

  table = TTY::Table.new(headers, data)
  puts table.render(:unicode, padding: [0, 1, 0, 1]) # Top, Right, Bottom, Left

  nil
end
