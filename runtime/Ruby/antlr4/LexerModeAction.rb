require '../antlr4/LexerAction'

class LexerModeAction < LexerAction
  attr_reader :mode


  def initialize(mode)
    @mode = mode
  end

  def getActionType()
    return LexerActionType::MODE
  end


  def isPositionDependent()
    return false
  end


  def execute(lexer)
    lexer.mode(@mode)
  end


  def hash()
    hashcode = 0
    hashcode = MurmurHash.update_int(hashcode, getActionType())
    hashcode = MurmurHash.update_int(hashcode, mode)
    return MurmurHash.finish(hashcode, 2)
  end


  def eql?(obj)
    if (obj == self)
      return true
    else
      if (!(obj.is_a? LexerModeAction))
        return false
      end
    end

    return @mode == obj.mode
  end


  def to_s()
    return "mode(" << @mode << ")"
  end
end
