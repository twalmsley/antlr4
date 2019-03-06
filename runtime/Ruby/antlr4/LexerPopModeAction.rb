require '../antlr4/LexerAction'
require 'singleton'

class LexerPopModeAction < LexerAction

  include Singleton

  def getActionType()
    return LexerActionType::POP_MODE
  end


  def isPositionDependent()
    return false
  end


  def execute(lexer)
    lexer.popMode()
  end


  def hash()
    hashcode = 0
    hashcode = MurmurHash.update_int(hashcode, getActionType())
    return MurmurHash.finish(hashcode, 1)
  end


  def equals(obj)
    return obj == self
  end


  def to_s()
    return "popMode"
  end
end
