require '../antlr4/Transition'


class WildcardTransition < Transition
  def initialize(target)
    super(target)
  end


  def getSerializationType()
    return WILDCARD
  end


  def matches(symbol, minVocabSymbol, maxVocabSymbol)
    return symbol >= minVocabSymbol && symbol <= maxVocabSymbol
  end


  def to_s()
    return "."
  end
end
