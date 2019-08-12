# frozen_string_literal: true

module AlpacaUnzip
  class EndOfCentralDirectory
    # end of central dir signature    4 bytes  (0x06054b50)
    # number of this disk             2 bytes
    # number of the disk with the
    # start of the central directory  2 bytes
    # total number of entries in the
    # central directory on this disk  2 bytes
    # total number of entries in
    # the central directory           2 bytes
    # size of the central directory   4 bytes
    # offset of start of central
    # directory with respect to
    # the starting disk number        4 bytes
    # .ZIP file comment length        2 bytes
    # .ZIP file comment       (variable size)
    Header = Struct.new(
      :signature,
      :number_of_this_disk,
      :number_of_disk_with_start_of_central_directory,
      :total_number_of_entries_in_central_directory_on_this_disk,
      :total_number_of_entries_in_central_directory,
      :size_of_central_directory,
      :offset_of_start_of_central_directory_with_respect_to_starting_disk_number,
      :comment_length
    ) do
      # @attr_accessor file_comment [String]
      attr_accessor :comment

      # @attr_accessor start_position [Integer]
      attr_accessor :start_position

      # @attr_accessor end_position [Integer]
      attr_accessor :end_position
    end

    # Parse binary of zip to CentralDirectory
    #
    # @param binary [AlpacaUnzip::Binary]
    # @param initial_position [Integer]
    #
    # @return [AlpacaUnzip::CentralDirectory]
    def self.parse(binary, initial_position)
      # Move to head of local file
      binary.seek(initial_position)

      signature = binary.read_little(4)
      number_of_this_disk = binary.read_u_short
      number_of_disk_with_start_of_central_directory = binary.read_u_short
      total_number_of_entries_in_central_directory_on_this_disk = binary.read_u_short
      total_number_of_entries_in_central_directory = binary.read_u_short
      size_of_central_directory = binary.read_u_int
      offset_of_start_of_central_directory_with_respect_to_starting_disk_number = binary.read_u_int
      comment_length = binary.read_u_short

      header = Header.new(
        signature,
        number_of_this_disk,
        number_of_disk_with_start_of_central_directory,
        total_number_of_entries_in_central_directory_on_this_disk,
        total_number_of_entries_in_central_directory,
        size_of_central_directory,
        offset_of_start_of_central_directory_with_respect_to_starting_disk_number,
        comment_length
      )

      comment = binary.read(header.comment_length)
      header.comment = comment

      # Set end position of local header
      header.start_position = initial_position
      header.end_position = binary.pos

      new(binary, header)
    end

    attr_reader :header

    # @param binary [AlpacaUnzip::Binary]
    # @param header [AlpacaUnzip::EndOfCentralDirectory::Header]
    def initialize(binary, header)
      @binary = binary
      @header = header
    end
  end
end
