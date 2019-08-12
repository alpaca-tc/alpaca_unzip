# frozen_string_literal: true

module AlpacaUnzip
  class Zip
    # @param source [File, String]
    def self.load_file(source)
      file = AlpacaUnzip::Binary.new(source)
      new(file)
    end

    attr_reader :local_files

    # @param file [File]
    def initialize(file)
      @file = file
      @local_files = parse_local_file_headers
    end

    private

    def parse_local_file_headers
      previous_position = @file.pos
      local_files = []

      while read_signature(@file) == "\x04\x03\x4b\x50"
        local_file = AlpacaUnzip::LocalFile.parse(@file, previous_position)
        local_files.push(local_file)

        # Move end position of local file for next section
        @file.seek(local_file.end_position)
      end

      local_files
    end

    # Read signature without seek
    def read_signature(file)
      current_position = file.pos

      file.read_little(4).tap do
        file.seek(current_position)
      end
    end
  end
end
