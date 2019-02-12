require '../../antlr4/runtime/Ruby/antlr4/PredictionContext'
require '../../antlr4/runtime/Ruby/antlr4/MurmurHash'

class SingletonPredictionContext < PredictionContext

  INITIAL_HASH = 1

  attr_accessor :parent
  attr_accessor :returnState

  def self.calculateEmptyHashCode()
    hash = INITIAL_HASH
    hash = MurmurHash.finish(hash, 0)
    return hash
  end

  def self.calculateHashCode(parents, returnStates)
    hash = MurmurHash.initialize(INITIAL_HASH)

    parents.each do |parent|
      hash = MurmurHash.update_obj(hash, parent)
    end

    returnStates.each do |returnState|
      hash = MurmurHash.update_int(hash, returnState)
    end

    hash = MurmurHash.finish(hash, 2 * parents.length)
    return hash
  end

  def initialize(parent, returnState)
    super(parent != nil ? SingletonPredictionContext.calculateHashCode(parent, returnState) : SingletonPredictionContext.calculateEmptyHashCode())
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
