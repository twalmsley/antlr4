require '../../antlr4/runtime/Ruby/antlr4/Transition'

class EpsilonTransition < Transition

  @outermostPrecedenceReturn


  def initialize(target, outermostPrecedenceReturn = -1)
    super(target)
    @outermostPrecedenceReturn = outermostPrecedenceReturn
  end


  def outermostPrecedenceReturn()
    return @outermostPrecedenceReturn
  end


  def getSerializationType()
    return EPSILON
  end


  def isEpsilon()
    return true
  end


  def matches(symbol, minVocabSymbol, maxVocabSymbol)
    return false
  end


  def to_s()
    return "epsilon"
  end
end
