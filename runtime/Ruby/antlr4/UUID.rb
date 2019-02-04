class Uuid
  attr_reader :upper
  attr_reader :lower

  def initialize(upper, lower)
    @lower = lower
    @upper = upper
  end

  def to_s
    @upper.to_s + @lower.to_s
  end

  def ==(other)
    if other != nil
      @lower == other.lower && @upper == other.upper
    else
      false
    end
  end

  def self.fromString(name)
    components = name.split("-")
    if (components.length != 5)
      raise IllegalArgumentException, "Invalid UUID string: " + name
    end

    upper = decode(components[0])
    upper = upper << 16
    upper = upper | decode(components[1])
    upper = upper << 16
    upper = upper | decode(components[2])

    lower = decode(components[3])
    lower = lower << 48
    lower = lower | decode(components[4])

    return Uuid.new(upper, lower)
  end

  def self.decode(hexString)
    hexString.to_i(16)
  end

end
