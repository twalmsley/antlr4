require '../antlr4/PredictionContext'

class ArrayPredictionContext < PredictionContext

  attr_accessor :parents
  attr_accessor :returnStates

  def initialize(parents, returnStates = nil)
    if parents.is_a? SingletonPredictionContext
      returnStates = [parents.returnState]
      parents = [parents.parent]
    end

    super(PredictionContextUtils.calculateHashCode_2(parents, returnStates))
    @parents = parents
    @returnStates = returnStates

  end

  def isEmpty()
# since EMPTY_RETURN_STATE can only appear in the last position, we
# don't need to verify that size==1
    return @returnStates[0] == EMPTY_RETURN_STATE
  end


  def size()
    return @returnStates.length
  end


  def getParent(index)
    return @parents[index]
  end


  def getReturnState(index)
    return @returnStates[index]
  end

  def equals(o)
    if (self == o)
      return true
    elsif (!(o.is_a? ArrayPredictionContext))
      return false
    end

    if (self.hash() != o.hash())
      return false # can't be same if hash is different
    end

    return (@returnStates.eql? o.returnStates) &&
        (@parents.eql? o.parents)
  end


  def to_s()
    if (isEmpty())
      return "[]"
    end
    buf = ""
    buf << "["
    i = 0
    while i < @returnStates.length
      if (i > 0)
        buf << ", "
      end
      if (returnStates[i] == EMPTY_RETURN_STATE)
        buf << "$"
        i += 1
        next
      end
      buf << @returnStates[i]
      if (@parents[i] != nil)
        buf << ' '
        buf << @parents[i].to_s()
      else
        buf << "nil"
      end
      i += 1
    end

    buf << "]"
    return buf.to_s
  end
end
