require '../antlr4/Transition'


class AtomTransition < Transition

  attr_reader :the_label

  def initialize(target, label)
    super(target)
    @the_label = label
  end


  def getSerializationType()
    return ATOM
  end


  def label()
    return IntervalSet.of(@the_label)
  end


  def matches(symbol, minVocabSymbol, maxVocabSymbol)
    return @the_label == symbol
  end


  def to_s()
    return "" + @the_label
  end
end
