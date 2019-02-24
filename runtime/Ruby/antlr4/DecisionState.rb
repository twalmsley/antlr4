require '../antlr4/ATNState'


class DecisionState < ATNState
  attr_accessor :decision
  @decision = -1
  attr_accessor :nonGreedy
  @nonGreedy = false
end
