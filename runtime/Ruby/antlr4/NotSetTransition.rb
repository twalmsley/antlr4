require '../antlr4/SetTransition'

class NotSetTransition < SetTransition
  def initialize(target, set)
    super(target, set)
  end

  def getSerializationType
    NOT_SET
  end

  def matches(symbol, minVocabSymbol, maxVocabSymbol)
    (symbol >= minVocabSymbol) && (symbol <= maxVocabSymbol) && !super
  end

  def to_s
    '~' + super.to_s
  end
end
