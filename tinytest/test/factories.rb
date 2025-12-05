# frozen_string_literal: true

module Factories
  class Sequence
    def initialize
      @counter = 0
    end

    def next
      @counter += 1
    end
  end

  SEQ = Sequence.new

  def insert_company(o = {})
    insert_into("companies", {
      name: o[:name] || "Company #{SEQ.next}"
    }.merge(o))
  end

  def insert_person(o = {})
    insert_into("people", {
      name: o[:name] || "Person #{SEQ.next}"
    }.merge(o))
  end

  def insert_position(o = {})
    insert_into("positions", {
      company_id: o[:company_id] || insert_company.id,
      person_id: o[:person_id] || insert_person.id,
      title: o[:title] || "CEO, Founder"
    }.merge(o))
  end

  private def insert_into(table, attrs)
    row = db.exec(<<~SQL, attrs.values).first
      INSERT INTO #{table} (
        #{attrs.keys.join(", ")}
      ) VALUES (
        #{(1..attrs.size).map { |i| "$#{i}" }.join(", ")}
      )
      RETURNING *
    SQL

    Data.define(*row.keys.map(&:to_sym)).new(*row.values)
  end
end
