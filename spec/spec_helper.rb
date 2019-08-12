# frozen_string_literal: true

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.filter_run_when_matching :focus
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.profile_examples = 10

  config.order = :random

  config.filter_gems_from_backtrace(
    'bootsnap',
    'spring-commands-rspec'
  )

  # Guard + springを使うと、seed値が固定されてしまう問題を修正
  # Randomize seed every time
  config.seed = srand % 0xFFFF unless ARGV.any? { |arg| arg =~ /seed/ }

  Kernel.srand config.seed
end
