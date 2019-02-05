require '../../antlr4/runtime/Ruby/antlr4/PredictionContext'


class SingletonPredictionContext < PredictionContext
  attr_accessor :parent
  attr_accessor :returnState

  def initialize(parent, returnState)
    super(parent != nil ? calculateHashCode(parent, returnState) : calculateEmptyHashCode())
    @parent = parent
    @returnState = returnState
  end

  def self.create(parent, returnState)
    if (returnState == EMPTY_RETURN_STATE && parent == nil)
      # someone can pass in the bits of an array ctx that mean $
      return EMPTY
    end
    return SingletonPredictionContext.new(parent, returnState)
  end

  def size()
    return 1
  end


  def getParent(index)
    return parent
  end


  def getReturnState(index)
    return returnState
  end

  def equals(o)
    if (this == o)
      return true
    elsif (!(o.is_a? SingletonPredictionContext))
      return false
    end

    if (self.hash() != o.hash())
      return false # can't be same if hash is different
    end

    s = o
    return returnState == s.returnState &&
        (parent != nil && parent.equals(s.parent))
  end


  def to_s()
    up = parent != nil ? parent.to_s() : ""
    if (up.length() == 0)
      if (returnState == EMPTY_RETURN_STATE)
        return "$"
      end
      return returnState.to_s
    end
    return returnState.to_s + " " + up
  end
end
