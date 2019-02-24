require '../antlr4/Transition'


class AtomTransition < Transition

  attr_reader :label

  def initialize(target, label)
    super(target)
    @label = label
  end


  def getSerializationType()
    return ATOM
  end


  def label()
    return IntervalSet.of(@label)
  end


  def matches(symbol, minVocabSymbol, maxVocabSymbol)
    return label == symbol
  end


  def to_s()
    return "" + label
  end
end
