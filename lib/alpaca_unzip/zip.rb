# frozen_string_literal: true

module AlpacaUnzip
  class Zip
    # @param source [File, String]
    def self.load_file(source)
      file = AlpacaUnzip::Binary.new(source)
      new(file)
    end

    attr_reader :local_files, :central_directories, :end_of_central_directory

    # @param file [File]
    def initialize(file)
      @file = file
      @local_files = parse_local_file_headers
      @central_directories = parse_central_directories
      @end_of_central_directory = parse_end_of_central_directory
    end

    private

    def parse_local_file_headers
      previous_position = @file.pos
      local_files = []

      while read_signature(@file) == "\x04\x03\x4b\x50"
        local_file = AlpacaUnzip::LocalFile.parse(@file, previous_position)
        local_files.push(local_file)

        # Move end position of local file for next section
        previous_position = local_file.end_position
        @file.seek(local_file.end_position)
      end

      local_files
    end

    def parse_central_directories
      previous_position = local_files.map(&:end_position).max
      central_directories = []

      while read_signature(@file) == "\x02\x01\x4b\x50"
        central_directory = AlpacaUnzip::CentralDirectory.parse(@file, previous_position)
        central_directories.push(central_directory)

        # Move end position of central directory for next section
        @file.seek(central_directory.header.end_position)
      end

      # TODO: 4.3.13 Digital signature:
      # TODO: 4.3.14  Zip64 end of central directory record
      # TODO: 4.3.15 Zip64 end of central directory locator

      central_directories
    end

    # 4.3.16  End of central directory record:
    def parse_end_of_central_directory
      if read_signature(@file) == "\x06\x05\x4b\x50"
        # End of central_directory
        AlpacaUnzip::EndOfCentralDirectory.parse(@file, @file.pos)
      else
        raise 'Invalid file given'
      end
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
