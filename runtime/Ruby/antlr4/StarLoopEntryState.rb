require '../../antlr4/runtime/Ruby/antlr4/DecisionState'


class StarLoopEntryState < DecisionState
  attr_accessor :loopBackState
  @loopBackState


  attr_accessor :isPrecedenceDecision
  @isPrecedenceDecision


  def getStateType()
    return STAR_LOOP_ENTRY
  end
end
