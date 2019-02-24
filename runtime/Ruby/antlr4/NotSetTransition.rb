require '../antlr4/SetTransition'


class NotSetTransition < SetTransition
  def initialize(target, set)
    super(target, set)
  end


  def getSerializationType()
    return NOT_SET
  end


  def matches(symbol, minVocabSymbol, maxVocabSymbol)
    return symbol >= minVocabSymbol && symbol <= maxVocabSymbol && !super.matches(symbol, minVocabSymbol, maxVocabSymbol)
  end


  def to_s()
    return '~' + super.to_s()
  end
end
