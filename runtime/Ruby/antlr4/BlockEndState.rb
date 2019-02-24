require '../antlr4/ATNState'


class BlockEndState < ATNState
  attr_accessor :startState
  @startState = nil


  def getStateType()
    return BLOCK_END
  end
end
