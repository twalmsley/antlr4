class TokenTagToken < CommonToken

  attr_reader :tokenName
  attr_reader :label

  def initialize(tokenName, type, label = nil)
    super(type)
    @tokenName = tokenName
    @label = label
  end

  def getText()
    if (@label != nil)
      return "<" + @label + ":" + @tokenName + ">"
    end

    return "<" + @tokenName + ">"
  end


  def to_s()
    return @tokenName + ":" + @type
  end
end
