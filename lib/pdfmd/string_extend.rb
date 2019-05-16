#
# Helper file with class extensions for string
#
class String

  #
  # Boolean function
  #
  #  'true|t|yes|y|1' == true
  #  'false|f|no|n|0' == false
  #  emtpy string is error
  #
  def to_bool
    return true if self == true || self =~ (/\A(true|t|yes|y|1)\Z/i)
    return false if self == false || self =~ (/\A(false|f|no|n|0)\Z/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end

  #
  # method to check if a string is empty
  #
  def blank?
    self.strip.empty?
  end
end 
