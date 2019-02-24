require '../antlr4/DecisionState'

class TokensStartState < DecisionState
  def getStateType()
    return TOKEN_START
  end
end
