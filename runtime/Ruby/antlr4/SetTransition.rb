require '../../antlr4/runtime/Ruby/antlr4/Transition'


class SetTransition < Transition
  attr_reader :set

  def initialize(target, set)
    super(target)
    if (set == nil)
      set = IntervalSet.of(Token.INVALID_TYPE)
    end

    @set = set
  end


  def getSerializationType()
    return SET
  end


  def label()
    return @set
  end


  def matches(symbol, minVocabSymbol, maxVocabSymbol)
    return set.contains(symbol)
  end


  def to_s()
    return set.to_s()
  end
end
