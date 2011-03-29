# SMPP v3.4 subset implementation.
# SMPP is a short message peer-to-peer protocol typically used to communicate 
# with SMS Centers (SMSCs) over TCP/IP.
#
# August Z. Flatby
# august@apparat.no

class String
  def valid_utf8?
    unpack("U") rescue nil
  end

  def split_u(n)
    if chars.entries.size <= n
      [self]
    else
      parts = []
      after = self
      until after.chars.entries.size <= n
        parts = parts + [after.chars.entries[0, n].to_s]
        after = after.chars.entries[n..-1].to_s
      end
      parts = parts + [after]
      return parts
    end
  end

  def non_ascii?
    self =~ /[^(\x20-\x7F\n\r)]+/
  end

  def size_u
    self.chars.entries.size
  end

def to_gsm7
    table = {
        "40" => "\x00",        # COMMERCIAL AT
        "A" => "\x0A",        # LINE FEED
        "C" => "\x1B\x0A",    # FORM FEED
        "D" => "\x0D",        # CARRIAGE RETURN
        "20" => "\x20",        # SPACE
        "21" => "\x21",        # EXCLAMATION MARK
        "22" => "\x22",        # QUOTATION MARK
        "23" => "\x23",        # NUMBER SIGN
        "24" => "\x02",        # DOLLAR SIGN
        "25" => "\x25",        # PERCENT SIGN
        "26" => "\x26",        # AMPERSAND
        "27" => "\x27",        # APOSTROPHE
        "28" => "\x28",        # LEFT PARENTHESIS
        "29" => "\x29",        # RIGHT PARENTHESIS
        "2a" => "\x2A",        # ASTERISK
        "2" => "\x2B",        # PLUS SIGN
        "2c" => "\x2C",        # COMMA
        "2d" => "\x2D",        # HYPHEN-MINUS
        "2e" => "\x2E",        # FULL STOP
        "2f" => "\x2F",        # SOLIDUS
        "30" => "\x30",        # DIGIT ZERO
        "31" => "\x31",        # DIGIT ONE
        "32" => "\x32",        # DIGIT TWO
        "33" => "\x33",        # DIGIT THREE
        "34" => "\x34",        # DIGIT FOUR
        "35" => "\x35",        # DIGIT FIVE
        "36" => "\x36",        # DIGIT SIX
        "37" => "\x37",        # DIGIT SEVEN
        "38" => "\x38",        # DIGIT EIGHT
        "39" => "\x39",        # DIGIT NINE
        "3a" => "\x3A",        # COLON
        "3b" => "\x3B",        # SEMICOLON
        "3c" => "\x3C",        # LESS-THAN SIGN
        "3d" => "\x3D",        # EQUALS SIGN
        "3e" => "\x3E",        # GREATER-THAN SIGN
        "3f" => "\x3F",        # QUESTION MARK
        "41" => "\x41",        # LATIN CAPITAL LETTER A
        "42" => "\x42",        # LATIN CAPITAL LETTER B
        "43" => "\x43",        # LATIN CAPITAL LETTER C
        "44" => "\x44",        # LATIN CAPITAL LETTER D
        "45" => "\x45",        # LATIN CAPITAL LETTER E
        "46" => "\x46",        # LATIN CAPITAL LETTER F
        "47" => "\x47",        # LATIN CAPITAL LETTER G
        "48" => "\x48",        # LATIN CAPITAL LETTER H
        "49" => "\x49",        # LATIN CAPITAL LETTER I
        "4a" => "\x4A",        # LATIN CAPITAL LETTER J
        "4b" => "\x4B",        # LATIN CAPITAL LETTER K
        "4c" => "\x4C",        # LATIN CAPITAL LETTER L
        "4d" => "\x4D",        # LATIN CAPITAL LETTER M
        "4e" => "\x4E",        # LATIN CAPITAL LETTER N
        "4f" => "\x4F",        # LATIN CAPITAL LETTER O
        "50" => "\x50",        # LATIN CAPITAL LETTER P
        "51" => "\x51",        # LATIN CAPITAL LETTER Q
        "52" => "\x52",        # LATIN CAPITAL LETTER R
        "53" => "\x53",        # LATIN CAPITAL LETTER S
        "54" => "\x54",        # LATIN CAPITAL LETTER T
        "55" => "\x55",        # LATIN CAPITAL LETTER U
        "56" => "\x56",        # LATIN CAPITAL LETTER V
        "57" => "\x57",        # LATIN CAPITAL LETTER W
        "58" => "\x58",        # LATIN CAPITAL LETTER X
        "59" => "\x59",        # LATIN CAPITAL LETTER Y
        "5a" => "\x5A",        # LATIN CAPITAL LETTER Z
        "5f" => "\x11",        # LOW LINE
        "61" => "\x61",        # LATIN SMALL LETTER A
        "62" => "\x62",        # LATIN SMALL LETTER B
        "63" => "\x63",        # LATIN SMALL LETTER C
        "64" => "\x64",        # LATIN SMALL LETTER D
        "65" => "\x65",        # LATIN SMALL LETTER E
        "66" => "\x66",        # LATIN SMALL LETTER F
        "67" => "\x67",        # LATIN SMALL LETTER G
        "68" => "\x68",        # LATIN SMALL LETTER H
        "69" => "\x69",        # LATIN SMALL LETTER I
        "6a" => "\x6A",        # LATIN SMALL LETTER J
        "6b" => "\x6B",        # LATIN SMALL LETTER K
        "6c" => "\x6C",        # LATIN SMALL LETTER L
        "6d" => "\x6D",        # LATIN SMALL LETTER M
        "6e" => "\x6E",        # LATIN SMALL LETTER N
        "6f" => "\x6F",        # LATIN SMALL LETTER O
        "70" => "\x70",        # LATIN SMALL LETTER P
        "71" => "\x71",        # LATIN SMALL LETTER Q
        "72" => "\x72",        # LATIN SMALL LETTER R
        "73" => "\x73",        # LATIN SMALL LETTER S
        "74" => "\x74",        # LATIN SMALL LETTER T
        "75" => "\x75",        # LATIN SMALL LETTER U
        "76" => "\x76",        # LATIN SMALL LETTER V
        "77" => "\x77",        # LATIN SMALL LETTER W
        "78" => "\x78",        # LATIN SMALL LETTER X
        "79" => "\x79",        # LATIN SMALL LETTER Y
        "7a" => "\x7A",        # LATIN SMALL LETTER Z
        "c" => "\x1B\x0A",    # FORM FEED
        "5b" => "\x1B\x3C",    # LEFT SQUARE BRACKET
        "5c" => "\x1B\x2F",    # REVERSE SOLIDUS
        "5d" => "\x1B\x3E",    # RIGHT SQUARE BRACKET
        "5e" => "\x1B\x14",    # CIRCUMFLEX ACCENT
        "7b" => "\x1B\x28",    # LEFT CURLY BRACKET
        "7c" => "\x1B\x40",    # VERTICAL LINE
        "7d" => "\x1B\x29",    # RIGHT CURLY BRACKET
        "7e" => "\x1B\x3D",    # TILDE
        "A0" => "\x1B",        # NO-BREAK SPACE
        "A1" => "\x40",        # INVERTED EXCLAMATION MARK
        "A3" => "\x01",        # POUND SIGN
        "A4" => "\x24",        # CURRENCY SIGN
        "A5" => "\x03",        # YEN SIGN
        "A7" => "\x5F",        # SECTION SIGN
        "bf" => "\x60",        # INVERTED QUESTION MARK
        "c4" => "\x5B",        # LATIN CAPITAL LETTER A WITH DIAERESIS
        "c5" => "\x0E",        # LATIN CAPITAL LETTER A WITH RING ABOVE
        "c6" => "\x1C",        # LATIN CAPITAL LETTER AE
        "c9" => "\x1F",        # LATIN CAPITAL LETTER E WITH ACUTE
        "d1" => "\x5D",        # LATIN CAPITAL LETTER N WITH TILDE
        "d6" => "\x5C",        # LATIN CAPITAL LETTER O WITH DIAERESIS
        "d8" => "\x0B",        # LATIN CAPITAL LETTER O WITH STROKE
        "dc" => "\x5E",        # LATIN CAPITAL LETTER U WITH DIAERESIS
        "df" => "\x1E",        # LATIN SMALL LETTER SHARP S
        "e0" => "\x7F",        # LATIN SMALL LETTER A WITH GRAVE
        "e4" => "\x7B",        # LATIN SMALL LETTER A WITH DIAERESIS
        "e5" => "\x0F",        # LATIN SMALL LETTER A WITH RING ABOVE
        "e6" => "\x1D",        # LATIN SMALL LETTER AE
        "e7" => "\x09",        # LATIN SMALL LETTER C WITH CEDILLA
        "e8" => "\x04",        # LATIN SMALL LETTER E WITH GRAVE
        "e9" => "\x05",        # LATIN SMALL LETTER E WITH ACUTE
        "ec" => "\x07",        # LATIN SMALL LETTER I WITH GRAVE
        "f1" => "\x7D",        # LATIN SMALL LETTER N WITH TILDE
        "f2" => "\x08",        # LATIN SMALL LETTER O WITH GRAVE
        "f6" => "\x7C",        # LATIN SMALL LETTER O WITH DIAERESIS
        "f8" => "\x0C",        # LATIN SMALL LETTER O WITH STROKE
        "f9" => "\x06",        # LATIN SMALL LETTER U WITH GRAVE
        "fc" => "\x7E",        # LATIN SMALL LETTER U WITH DIAERESIS
        "393" => "\x13",        # GREEK CAPITAL LETTER GAMMA
        "394" => "\x10",        # GREEK CAPITAL LETTER DELTA
        "398" => "\x19",        # GREEK CAPITAL LETTER THETA
        "39b" => "\x14",        # GREEK CAPITAL LETTER LAMDA
        "39e" => "\x1A",        # GREEK CAPITAL LETTER XI
        "3a0" => "\x16",        # GREEK CAPITAL LETTER PI
        "3a3" => "\x18",        # GREEK CAPITAL LETTER SIGMA
        "3a6" => "\x12",        # GREEK CAPITAL LETTER PHI
        "3a8" => "\x17",        # GREEK CAPITAL LETTER PSI
        "3a9" => "\x15",        # GREEK CAPITAL LETTER OMEGA
        "20ac" => "\x1B\x65",    # EURO SIGN
    }

    result = ""
    text = self
    text.chars.entries.each do |char|
        if code = table[char[0].to_s(16)]
            result += code.to_s
        end
    end
    result
  end

end

require 'logger'

$:.unshift(File.dirname(__FILE__))
require 'smpp/base.rb'
require 'smpp/transceiver.rb'
require 'smpp/optional_parameter'
require 'smpp/pdu/base.rb'
require 'smpp/pdu/bind_base.rb'
require 'smpp/pdu/bind_resp_base.rb'

# Load all PDUs
Dir.glob(File.join(File.dirname(__FILE__), 'smpp', 'pdu', '*.rb')) do |f|
  require f unless f.match('base.rb$')
end

# Default logger. Invoke this call in your client to use another logger.
Smpp::Base.logger = Logger.new(STDOUT)
