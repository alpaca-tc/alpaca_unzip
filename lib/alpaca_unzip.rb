# frozen_string_literal: true

require 'alpaca_unzip/version'

module AlpacaUnzip
  # TODO: Replace the follows code with `autoload` or `require`
  Dir[File.expand_path('alpaca_unzip/**/*', __dir__)].each { |path| require(path) }
end
