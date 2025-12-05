# TinyTest

A minimal Ruby test framework extracted from [Dan Croak's blog post](https://dancroak.com/ruby/test/).

## Features

- **Single assertion**: `ok` - passes if expression is truthy
- **Transaction rollback**: Each test runs in a database transaction that rolls back
- **Object stubs**: Create test doubles with `stub(method: return_value)`
- **Class stubs**: Temporarily replace class methods with `stub_class(Klass, method: value)`
- **Spy assertions**: Track calls with `called?(:method)` and `calls[:method]`
- **Factories**: Simple database factories with auto-incrementing sequences
- **Randomized order**: Tests run in random order with reproducible seed
- **Focus mode**: Run single test with `--name test_method_name`

## Usage

### Basic Test

```ruby
class MathTest < Test
  def test_addition
    ok 2 + 2 == 4
  end

  def test_with_message
    result = calculate_something
    ok result > 0, "expected positive result, got #{result}"
  end
end
```

### Running Tests

```bash
# Run all tests
ruby test/suite.rb

# Run with specific seed (reproducible)
ruby test/suite.rb --seed 1234

# Run single test
ruby test/suite.rb --name test_addition
```

### Stubs

```ruby
class ApiTest < Test
  def test_with_stub
    client = stub(fetch: {data: "value"})

    result = MyService.new(client).call

    ok result == "value"
    ok client.called?(:fetch)
  end

  def test_with_lambda_stub
    client = stub(
      transform: ->(text) { text.upcase }
    )

    ok client.transform("hello") == "HELLO"
  end
end
```

### Class Method Stubs

```ruby
class TimeTest < Test
  def test_frozen_time
    stub_class(Time, now: Time.at(0))

    ok Time.now == Time.at(0)
  end
  # Original Time.now is restored after test
end
```

### Factories

```ruby
class CompanyTest < Test
  def test_create_company
    co = insert_company(name: "Acme Inc")

    ok co.name == "Acme Inc"
  end

  def test_with_relationships
    co = insert_company
    per = insert_person(name: "Jane")
    pos = insert_position(company_id: co.id, person_id: per.id)

    ok pos.company_id == co.id
  end
end
```

## File Structure

```
tinytest/
├── lib/
│   └── db.rb              # Database connection (customize this)
├── test/
│   ├── test_helper.rb     # Core test framework
│   ├── factories.rb       # Test data factories
│   ├── suite.rb           # Load all tests
│   ├── ruby_suite.rb      # Load non-controller tests
│   ├── rails_suite.rb     # Load controller tests
│   ├── rails_helper.rb    # Rails/Rack test helpers
│   ├── controllers/       # Controller tests
│   │   └── *_test.rb
│   └── *_test.rb          # Unit tests
└── README.md
```

## Dependencies

- `webmock` - HTTP request stubbing
- `pg` - PostgreSQL (for database tests)
- `rack-test` - Controller testing (Rails apps)

## Configuration

Edit `lib/db.rb` to configure your database connection:

```ruby
DB.configure do |c|
  c.pool_size = 1
  c.database_url = ENV["DATABASE_URL"]
end
```

## Style Guide

- Use `got`/`want` variables for comparisons
- Separate setup/exercise/assertion phases with blank lines
- Use `db_` prefix for database query results
- Use heredocs for complex SQL queries
