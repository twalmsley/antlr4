require '../antlr4/LexerAction'

class LexerIndexedCustomAction < LexerAction

  attr_reader :action
  attr_reader :offset

  def initialize(offset, action)
    @offset = offset
    @action = action
  end

  def getActionType()
    return @action.getActionType()
  end


  def isPositionDependent()
    return true
  end


  def execute(lexer)
# assume the input stream position was properly set by the calling code
    @action.execute(lexer)
  end


  def hash()
    hash = 0
    hash = MurmurHash.update_int(hash, offset)
    hash = MurmurHash.update_obj(hash, action)
    return MurmurHash.finish(hash, 2)
  end


  def eql?(obj)
    if (obj == self)
      return true
    else
      if (!(obj.is_a? LexerIndexedCustomAction))
        return false
      end
    end

    return @offset == obj.offset && @action == obj.action
  end

end
