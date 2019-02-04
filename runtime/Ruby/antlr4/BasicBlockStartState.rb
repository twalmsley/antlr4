require '../../antlr4/runtime/Ruby/antlr4/BlockStartState'

class BasicBlockStartState < BlockStartState

  def getStateType()
    return BLOCK_START
  end
end
