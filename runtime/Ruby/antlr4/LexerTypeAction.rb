require '../antlr4/LexerAction'

class LexerTypeAction < LexerAction
  attr_reader :type


  def initialize(type)
    @type = type
  end

  def getActionType()
    return LexerActionType::TYPE
  end


  def isPositionDependent()
    return false
  end


  def execute(lexer)
    lexer.setType(@type)
  end


  def hash()
    hashcode = 0
    hashcode = MurmurHash.update_int(hashcode, getActionType())
    hashcode = MurmurHash.update_int(hashcode, @type)
    return MurmurHash.finish(hashcode, 2)
  end


  def eql?(obj)
    if (obj == self)
      return true
    else
      if (!(obj.is_a? LexerTypeAction))
        return false
      end
    end
    return @type == obj.type
  end


  def to_s()
    return "type(" << @type << ")"
  end
end
