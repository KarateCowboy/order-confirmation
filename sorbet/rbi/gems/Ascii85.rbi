# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: strict
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/Ascii85/all/Ascii85.rbi
#
# Ascii85-1.0.3

module Ascii85
  def self.decode(str); end
  def self.encode(str, wrap_lines = nil); end
end
class Ascii85::DecodingError < StandardError
end
