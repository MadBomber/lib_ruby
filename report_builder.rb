# report_builder.rb
# from https://tech.lendinghome.com/a-case-for-composition-ed4a0daf79be#.eskq75n2h

class ReportBuilder
  def csv_report(objects, adapter, opts = {})
    writer = CsvWriter.new(adapter)

    objects.each do |object|
      writer.write_object(object, opts)
    end

    writer.to_s
  end
end # class ReportBuilder

class CsvWriter
  attr_reader :rows

  def initialize(adapter)
    @adapter = adapter
    @rows = []
  end

  def write_objects(objects)
    objects.each do |object|
      write_object(object)
    end
  end

  def write_object(object)
    @rows << @adapter.object_to_hash(object)
  end

  def to_s
    headers = calculate_headers
    CSV.generate('', { headers: headers }) do |csv|
      @rows.each{ |row| csv.add_row(write_row(headers, row)) }
    end
  end

  private

  def calculate_headers
    @rows.first.keys
  end

  def write_row(headers, row)
    csv_row = CSV::Row.new(headers, [])
    row.each{ |key, value| csv_row[key] = value }
    csv_row
  end
end # class CsvWriter


__END__

class LoanAdapter
  def object_to_hash(loan)
    {
      "Loan Number" =>          loan.number,
      "Gross Interest Rate" =>  loan.interest_rate,
      "Maturity Date" =>        loan.closing.payment_last_date,
      "Loan Payment Status" =>  loan.servicing_state,
      "As-is Value LTV" =>      loan.initial_to_original,
      "After-rehab LTV" =>      loan.loan_to_repaired,
      "Effective LTV" =>        loan.ltv_max
    }
  end
end
