require '../../antlr4/runtime/Ruby/antlr4/DecisionState'


class StarLoopEntryState < DecisionState
  attr_accessor :loopBackState
  @loopBackState = nil


  attr_accessor :isPrecedenceDecision
  @isPrecedenceDecision = false


  def getStateType()
    return STAR_LOOP_ENTRY
  end
end
