# frozen_string_literal: true

module AlpacaUnzip
  class LocalFile
    # == LocalFileHeader
    #
    # local file header signature     4 bytes  (0x04034b50)
    # version needed to extract       2 bytes
    # general purpose bit flag        2 bytes
    # compression method              2 bytes
    # last mod file time              2 bytes
    # last mod file date              2 bytes
    # crc-32                          4 bytes
    # compressed size                 4 bytes
    # uncompressed size               4 bytes
    # file name length                2 bytes
    # extra field length              2 bytes
    #
    # file name (variable size)
    # extra field (variable size)
    Header = Struct.new(
      :signature,
      :version,
      :general_purpose_bit_flag,
      :compression_method,
      :last_modified_file_time,
      :last_modified_file_date,
      :crc_32,
      :compressed_size,
      :uncompressed_size,
      :file_name_length,
      :extra_field_length
    ) do
      # @attr_reader filename [String]
      attr_accessor :filename

      # @attr_reader start_position [Integer]
      attr_accessor :start_position

      # @attr_reader end_position [Integer]
      attr_accessor :end_position

      # @attr_reader extra_fields [Array<AlpacaUnzip::ExtraField>]
      attr_reader :extra_fields

      # Initialize header of local file
      def initialize(*)
        super
        @extra_fields = []
      end

      # Add extra field
      #
      # @return [void]
      def add_extra_field(id, content)
        @extra_fields << AlpacaUnzip::ExtraField.parse(id, content)
      end
    end

    # Parse binary of zip to LocalFile
    #
    # @param binary [AlpacaUnzip::Binary]
    # @param initial_position [Integer]
    #
    # @return [AlpacaUnzip::LocalFile]
    def self.parse(binary, initial_position)
      # Move to head of local file
      binary.seek(initial_position)

      signature = binary.read_little(4)
      version = binary.read_little(2)
      general_purpose_bit_flag = binary.read_little(2)
      compression_method = binary.read_little(2)
      last_modified_file_time = binary.read_u_short
      last_modified_file_date = binary.read_u_short
      crc_32 = binary.read_u_int
      compressed_size = binary.read_u_int
      uncompressed_size = binary.read_u_int
      file_name_length = binary.read_u_short
      extra_field_length = binary.read_u_short

      header = Header.new(
        signature,
        version,
        general_purpose_bit_flag,
        compression_method,
        last_modified_file_time,
        last_modified_file_date,
        crc_32,
        compressed_size,
        uncompressed_size,
        file_name_length,
        extra_field_length
      )

      # REVIEW: Should I convert to UTF-8?
      filename = binary.read(header.file_name_length)
      header.filename = filename

      # Each extra field is 4byte
      extra_field_size = extra_field_length / 4
      extra_field_size.times do
        id = binary.read_u_short
        content = binary.read_little(2)

        header.add_extra_field(id, content)
      end

      # Set end position of local header
      header.start_position = initial_position
      header.end_position = binary.pos

      new(binary, header)
    end

    attr_reader :header

    # @param binary [AlpacaUnzip::Binary]
    # @param header [AlpacaUnzip::LocalFile::Header]
    def initialize(binary, header)
      @binary = binary
      @header = header
    end

    # Returns parsed body of file
    #
    # @return [String]
    def body
      @body ||= parse_body
    end

    # Returns end position of local file
    #
    # @return [Integer]
    def end_position
      # TODO: Support compressed zip
      header.end_position + header.compressed_size
    end

    private

    attr_reader :binary

    def parse_body
      # TODO: Support compressed zip
      binary.seek(header.end_position)
      binary.read(header.compressed_size)
    end
  end
end
