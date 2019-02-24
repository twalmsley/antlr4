require '../antlr4/PredictionContext'
require '../antlr4/MurmurHash'

class SingletonPredictionContext < PredictionContext

  attr_accessor :parent
  attr_accessor :returnState

  def initialize(parent, returnState)
    super(parent != nil ? SingletonPredictionContext.calculateHashCode_1(parent, returnState) : SingletonPredictionContext.calculateEmptyHashCode())
    @parent = parent
    @returnState = returnState
  end

  def size()
    return 1
  end


  def getParent(index)
    return @parent
  end

  def isEmpty()
    return @returnState == EMPTY_RETURN_STATE
  end


  def getReturnState(index)
    return @returnState
  end

  def equals(o)
    if (self == o)
      return true
    elsif (!(o.is_a? SingletonPredictionContext))
      return false
    end

    if (self.hash() != o.hash())
      return false # can't be same if hash is different
    end

    s = o
    return @returnState == s.returnState &&
        (@parent != nil && @parent.equals(s.parent))
  end


  def to_s()
    up = @parent != nil ? @parent.to_s() : ""
    if (up.length() == 0)
      if (@returnState == EMPTY_RETURN_STATE)
        return "$"
      end
      return @returnState.to_s
    end
    return @returnState.to_s + " " + up
  end
end
