require '../antlr4/TerminalNodeImpl'

class ErrorNodeImpl < TerminalNodeImpl
  def initialize(token)
    super(token)
  end


  def accept(visitor)
    return visitor.visitErrorNode(self)
  end
end
