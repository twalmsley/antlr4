require '../antlr4/SingletonPredictionContext'
require '../antlr4/PredictionContextUtils'

class EmptyPredictionContext < SingletonPredictionContext

  def initialize(returnState)
    super(nil, returnState)
  end

  EMPTY = EmptyPredictionContext.new(PredictionContextUtils::EMPTY_RETURN_STATE)

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


  def to_s()
    return "$"
  end
end
