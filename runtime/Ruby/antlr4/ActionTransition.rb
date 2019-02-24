require '../antlr4/Transition'

class ActionTransition < Transition

  def initialize(target, ruleIndex, actionIndex, isCtxDependent)
    super(target)
    @ruleIndex = ruleIndex
    @actionIndex = actionIndex
    @isCtxDependent = isCtxDependent
  end

  def getSerializationType()
    return ACTION
  end

  def isEpsilon()
    return true
  end

  def matches(symbol, minVocabSymbol, maxVocabSymbol)
    return false
  end

  def toString()
    return "action_" + @ruleIndex + ":" + @actionIndex
  end
end