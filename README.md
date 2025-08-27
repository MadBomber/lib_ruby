 # lib/ruby

 A collection of Ruby utility libraries, extensions, and scripts—many dating back to Ruby 1.8.7, some modern and backed by unit tests.

 ## Table of Contents
 - [Overview](#overview)
 - [Installation](#installation)
 - [Getting Started](#getting-started)
 - [Modules & Utilities](#modules--utilities)
   - [ActiveRecord Extensions](#activerecord-extensions)
   - [Algorithms & Data Structures](#algorithms--data-structures)
   - [Coordinate Systems](#coordinate-systems)
   - [Shell & System Utilities](#shell--system-utilities)
   - [Feature Toggles & Workflow](#feature-toggles--workflow)
   - [Miscellaneous Utilities](#miscellaneous-utilities)
 - [Examples](#examples)
 - [Testing](#testing)
 - [Contributing](#contributing)
 - [License](#license)

 ## Overview

 This repository bundles a diverse set of Ruby-based helpers:
 - **Legacy code** (Ruby 1.8/1.9) that may require updating.
 - **Modern utilities**, many backed by unit tests.
 - **Experimental and demo scripts**, educational rather than production-ready.

 ## Installation

 Use Bundler or clone and load files directly:

 ```bash
 git clone https://github.com/yourorg/lib-ruby.git
 cd lib-ruby
 bundle install
 ```

 ## Getting Started

 Require modules individually:
 ```ruby
 require 'data_structures_101/priority_queue'
 require 'coordinates/utm_coordinate'
 require 'password_validator'
 ```

 Or load all utilities:
 ```ruby
 Dir['lib/**/*.rb'].each { |f| require_relative f }
 ```

 ## Modules & Utilities

 ### ActiveRecord Extensions
 - `active_record_better_native_database_types.rb` — Enhanced DB type mapping.
 - `active_record_extensions/` — Autowire, add comments, and other AR extensions.

 ### Algorithms & Data Structures
 - `data_structures_101/` — Queues, locks, and sorting algorithms.
 - `priority_queue.rb`, `linked_list.rb`, `hash_recursive_merge.rb`.
 - Educational demos: `pancake_sort.rb`, `bogosort.rb`, `random_forest_classifier.rb`.

 ### Coordinate Systems
 - `coordinates/` — Convert between UTM, MGRS, web Mercator, British National Grid, and more.

 ### Shell & System Utilities
 - `bash_system.rb`, `shell_command_executor.rb` — Secure shell execution.
 - Rake helpers: `tasks/`, `rake_tasks/`.

 ### Feature Toggles & Workflow
 - `simple_feature_flags.rb`, `feature_toggle.rb` — Runtime toggles.
 - `simple_flow.rb` — Build chained workflows.

 ### Miscellaneous Utilities
 - Date helpers: `date_helpers.rb`, `easter_sunday.rb`, `previous_dow.rb`.
 - String and Hash refinements: `mods/`, `refinements_*.rb`.
 - `password_validator.rb`, `uuidv7.rb`, `cache.rb`, `diff.rb`.

 ## Examples

 See the `examples/` directory for sample scripts demonstrating usage patterns.

 ## Testing

 Run unit tests under `tests/`:
 ```bash
 bundle exec rake test
 ```

 ## Contributing

 Pull requests welcome! Please follow the [Improvement Plan](improvement_plan.md), run RuboCop and tests, and submit PRs.

 ## License

 This project does not include a license file. Please add `LICENSE` to clarify usage rights.

