# frozen_string_literal: true

module AlpacaUnzip
  class ExtraField
    # TODO: Dispatch chunk initializer by id
    # @param id [Integer]
    # @param raw_content [String]
    #
    # @return [AlpacaUnzip::ExtraField]
    def self.parse(id, raw_content)
      new(id, raw_content)
    end

    attr_reader :id, :raw_content

    # @param id [Integer] ID of extra field
    # @param raw_content [String] Binary string of extra field
    def initialize(id, raw_content)
      @id = id
      @raw_content = raw_content
    end
  end
end
