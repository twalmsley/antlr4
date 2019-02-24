require '../antlr4/Transition'


class RangeTransition < Transition
  attr_reader :from
  attr_reader :to

  def initialize(target, from, to)
    super(target)
    @from = from
    @to = to
  end


  def getSerializationType()
    return RANGE
  end


  def label()
    return IntervalSet.of(@from, @to)
  end


  def matches(symbol, minVocabSymbol, maxVocabSymbol)
    return symbol >= @from && symbol <= @to
  end


  def to_s()
    "'" << @from << "'..'" << @to << "'"
  end
end
