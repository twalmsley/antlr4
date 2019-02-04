require '../antlr4/ATN'
require '../antlr4/ATNState'

atn = ATN.new(0, 100)

atn.nextTokens_ctx(ATNState.new, RuleContext.new)
atn.nextTokens(ATNState.new)
atn.addState(ATNState.new)
atn.removeState(ATNState.new)
atn.defineDecisionState(DecisionState.new)