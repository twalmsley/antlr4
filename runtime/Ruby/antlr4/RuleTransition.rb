require '../antlr4/Transition'


class RuleTransition < Transition

  attr_reader :ruleIndex # no Rule object at runtime

  attr_reader :precedence


  attr_reader :followState


  def initialize(ruleStart,
                 ruleIndex,
                 precedence,
                 followState)

    super(ruleStart)
    @ruleIndex = ruleIndex
    @precedence = precedence
    @followState = followState
  end


  def getSerializationType()
    return RULE
  end


  def isEpsilon()
    return true
  end


  def matches(symbol, minVocabSymbol, maxVocabSymbol)
    return false
  end
end
