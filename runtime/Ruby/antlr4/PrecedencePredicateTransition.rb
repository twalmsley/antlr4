require '../../antlr4/runtime/Ruby/antlr4/AbstractPredicateTransition'


class PrecedencePredicateTransition < AbstractPredicateTransition
  attr_reader :precedence

  def initialize(target, precedence)
    super(target)
    @precedence = precedence
  end


  def getSerializationType()
    return PRECEDENCE
  end


  def isEpsilon()
    return true
  end


  def matches(symbol, minVocabSymbol, maxVocabSymbol)
    return false
  end

  def getPredicate()
    return SemanticContext.PrecedencePredicate.new(precedence)
  end


  def to_s()
    return precedence + " >= _p"
  end

end
