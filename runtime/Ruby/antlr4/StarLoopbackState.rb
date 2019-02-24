require '../antlr4/ATNState'


class StarLoopbackState < ATNState
  def getLoopEntryState()
    return transition(0).target
  end


  def getStateType()
    return STAR_LOOP_BACK
  end
end
