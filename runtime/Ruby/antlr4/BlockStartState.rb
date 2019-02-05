require '../../antlr4/runtime/Ruby/antlr4/DecisionState'
class BlockStartState < DecisionState
  attr_accessor :endState
  @endState = nil
end
