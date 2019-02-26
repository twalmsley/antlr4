require '../antlr4/TerminalNode'


class TerminalNodeImpl < TerminalNode
  attr_accessor :symbol
  attr_accessor :parent

  def initialize(symbol)
    @symbol = symbol
  end


  def getChild(i)
    return nil
  end


  def getPayload()
    return @symbol
  end


  def getSourceInterval()
    if (@symbol == nil)
      return Interval.INVALID
    end

    tokenIndex = @symbol.getTokenIndex()
    return Interval.new(tokenIndex, tokenIndex)
  end


  def getChildCount()
    return 0
  end


  def accept(visitor)
    return visitor.visitTerminal(self)
  end


  def getText()
    return @symbol.getText()
  end


  def toStringTree(parser = nil)
    return to_s()
  end


  def to_s()
    if (@symbol.getType() == Token::EOF)
      return "<EOF>"
    end
    return @symbol.getText()
  end


end
