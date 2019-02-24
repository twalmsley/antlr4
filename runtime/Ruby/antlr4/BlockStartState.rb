require '../antlr4/DecisionState'
class BlockStartState < DecisionState
  attr_accessor :endState
  @endState = nil
end
