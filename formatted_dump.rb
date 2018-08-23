# lib/ruby/formatted_dump.rb
# Creates a string that can be puts to IO that consists
# of a formatted hex/ascii dump of an Array of bytes or a String object

class FormattedDump

  class << self

    def call(an_array_or_string)
      byte_array = an_array_or_string.is_a?(String) ? an_array_or_string.bytes : an_array_or_string

      result = ''
      offset = 0
      byte_array.each_slice(16) do |bytes|
        result << format_line(offset, bytes) << "\n"
        offset += 16
      end
      result
    end


    def bytes_as_hex(bytes)
      bytes.map { |b| "%02X" % b }.join(' ')
    end


    def offset_string(offset)
      "0x%04X" % [offset]
    end


    def join_hex_sections(sections)
      sections.join(' -- ')
    end


    def ascii_char(byte)
      (32..126).include?(byte) ? byte.chr : '.'
    end


    def ascii_string(bytes)
      bytes.map { |b| ascii_char(b) }.join
    end


    def format_line(offset, bytes)
      sections = bytes.each_slice(4).to_a.map { |slice| bytes_as_hex(slice) }

      a_line  = offset_string(offset) + '  '                  # buffer offset in hex
      # NOTE: Magic Number (16+3)*3 -1 #=> 56
      #       Thats 16 bytes + 3 seperators of 3 spaces each
      #       except for the last byte which only occupies 2 spaces hence the -1
      #       used to space fill the last line of a buffer which might have
      #       less that the full line of 16 bytes.
      a_line += join_hex_sections(sections).ljust(56) + '  '  # the hex part
      a_line += ascii_string(bytes)                           # the ASCII part
    end

  end # class << self
end # class FormattedDump

__END__

array = Array.new(265) { |i| i%256 }
puts FormattedDump.(array)

>> puts FormattedDump.(array) #=> nil
0x0000  00 01 02 03 -- 04 05 06 07 -- 08 09 0A 0B -- 0C 0D 0E 0F  ................
0x0010  10 11 12 13 -- 14 15 16 17 -- 18 19 1A 1B -- 1C 1D 1E 1F  ................
0x0020  20 21 22 23 -- 24 25 26 27 -- 28 29 2A 2B -- 2C 2D 2E 2F   !"#$%&'()*+,-./
0x0030  30 31 32 33 -- 34 35 36 37 -- 38 39 3A 3B -- 3C 3D 3E 3F  0123456789:;<=>?
0x0040  40 41 42 43 -- 44 45 46 47 -- 48 49 4A 4B -- 4C 4D 4E 4F  @ABCDEFGHIJKLMNO
0x0050  50 51 52 53 -- 54 55 56 57 -- 58 59 5A 5B -- 5C 5D 5E 5F  PQRSTUVWXYZ[\]^_
0x0060  60 61 62 63 -- 64 65 66 67 -- 68 69 6A 6B -- 6C 6D 6E 6F  `abcdefghijklmno
0x0070  70 71 72 73 -- 74 75 76 77 -- 78 79 7A 7B -- 7C 7D 7E 7F  pqrstuvwxyz{|}~.
0x0080  80 81 82 83 -- 84 85 86 87 -- 88 89 8A 8B -- 8C 8D 8E 8F  ................
0x0090  90 91 92 93 -- 94 95 96 97 -- 98 99 9A 9B -- 9C 9D 9E 9F  ................
0x00A0  A0 A1 A2 A3 -- A4 A5 A6 A7 -- A8 A9 AA AB -- AC AD AE AF  ................
0x00B0  B0 B1 B2 B3 -- B4 B5 B6 B7 -- B8 B9 BA BB -- BC BD BE BF  ................
0x00C0  C0 C1 C2 C3 -- C4 C5 C6 C7 -- C8 C9 CA CB -- CC CD CE CF  ................
0x00D0  D0 D1 D2 D3 -- D4 D5 D6 D7 -- D8 D9 DA DB -- DC DD DE DF  ................
0x00E0  E0 E1 E2 E3 -- E4 E5 E6 E7 -- E8 E9 EA EB -- EC ED EE EF  ................
0x00F0  F0 F1 F2 F3 -- F4 F5 F6 F7 -- F8 F9 FA FB -- FC FD FE FF  ................
0x0100  00 01 02 03 -- 04 05 06 07 -- 08                          .........
