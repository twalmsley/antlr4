require '../../antlr4/runtime/Ruby/antlr4/SingletonPredictionContext'

class EmptyPredictionContext < SingletonPredictionContext
  def initialize()
    super(nil, EMPTY_RETURN_STATE)
  end


  def isEmpty()
    return true
  end


  def size()
    return 1
  end


  def getParent(index)
    return nil
  end


  def getReturnState(index)
    return returnState
  end


  def equals(o)
    return self == o
  end


  def t_s()
    return "$"
  end
end
