require '../antlr4/BlockStartState'


class PlusBlockStartState < BlockStartState
  attr_accessor :loopBackState
  @loopBackState = nil


  def getStateType()
    return PLUS_BLOCK_START
  end
end
