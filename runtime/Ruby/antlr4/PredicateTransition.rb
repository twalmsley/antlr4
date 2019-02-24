require '../antlr4/AbstractPredicateTransition'


class PredicateTransition < AbstractPredicateTransition
  attr_reader :ruleIndex
  attr_reader :predIndex
  attr_reader :isCtxDependent # e.g., $i ref in pred

  def initialize(target, ruleIndex, predIndex, isCtxDependent)
    super(target)
    @ruleIndex = ruleIndex
    @predIndex = predIndex
    @isCtxDependent = isCtxDependent
  end


  def getSerializationType()
    return PREDICATE
  end


  def isEpsilon()
    return true
  end


  def matches(symbol, minVocabSymbol, maxVocabSymbol)
    return false
  end

  def getPredicate()
    return SemanticContext.Predicate.new(@ruleIndex, @predIndex, @isCtxDependent)
  end


  def to_s()
    return "pred_" + @ruleIndex + ":" + @predIndex
  end

end
