# frozen_string_literal: true

module AlpacaUnzip
  # Extend ::File class for accessing binary
  class Binary < ::File
    # NOTE: zip binary is little endian
    FORMATS = {
      u_long_long: {
        length: 8,
        code: 'Q<'
      },
      long_long: {
        length: 8,
        code: 'q<'
      },
      double: {
        length: 8,
        code: 'G'
      },
      float: {
        length: 4,
        code: 'F'
      },
      u_int: {
        length: 4,
        code: 'L<'
      },
      int: {
        length: 4,
        code: 'l<'
      },
      u_short: {
        length: 2,
        code: 'S<'
      },
      short: {
        length: 2,
        code: 's<'
      }
    }.freeze

    FORMATS.each do |format, info|
      define_method "read_#{format}" do
        read(info[:length]).unpack1(info[:code])
      end

      define_method "read_#{format}_pad2" do
        pad2(public_send("read_#{format}"))
      end

      define_method "read_#{format}_pad4" do
        pad4(public_send("read_#{format}"))
      end
    end

    # Read big endian
    #
    # @return [String]
    def read_big(length)
      read(length)
    end

    # Read little endian
    #
    # @return [String]
    def read_little(length)
      read_big(length).reverse
    end

    private

    def pad2(i)
      (i + 1) & ~0x01
    end

    def pad4(i)
      ((i + 4) & ~0x03) - 1
    end
  end
end
