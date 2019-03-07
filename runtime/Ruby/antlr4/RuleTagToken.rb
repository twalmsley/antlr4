require '../antlr4/Token'

class RuleTagToken < Token

  attr_reader :ruleName
  attr_reader :bypassTokenType
  attr_reader :label

  def initialize(ruleName, bypassTokenType, label = nil)
    if (ruleName == nil || ruleName.isEmpty())
      raise IllegalArgumentException, "ruleName cannot be nil or empty."
    end

    @ruleName = ruleName
    @bypassTokenType = bypassTokenType
    @label = label
  end

  def getChannel()
    return DEFAULT_CHANNEL
  end


  def getText()
    if (@label != nil)
      return "<" + @label + ":" + @ruleName + ">"
    end

    return "<" + @ruleName + ">"
  end


  def getType()
    return @bypassTokenType
  end


  def getLine()
    return 0
  end


  def getCharPositionInLine()
    return -1
  end


  def getTokenIndex()
    return -1
  end


  def getStartIndex()
    return -1
  end


  def getStopIndex()
    return -1
  end


  def getTokenSource()
    return nil
  end


  def getInputStream()
    return nil
  end


  def to_s()
    return @ruleName + ":" + @bypassTokenType
  end

end
