require '../antlr4/ATNState'


class LoopEndState < ATNState
  attr_accessor :loopBackState
  @loopBackState = nil


  def getStateType()
    return LOOP_END
  end
end
