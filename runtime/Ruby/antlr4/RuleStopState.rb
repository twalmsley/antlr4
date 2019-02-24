require '../antlr4/ATNState'


class RuleStopState < ATNState


  def getStateType()
    return RULE_STOP
  end

end
