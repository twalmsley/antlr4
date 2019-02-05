require '../../antlr4/runtime/Ruby/antlr4/ATNState'


class RuleStartState < ATNState
  attr_accessor :stopState
  @stopState = nil
  attr_accessor :isLeftRecursiveRule
  @isLeftRecursiveRule = false


  def getStateType()
    return RULE_START
  end
end
