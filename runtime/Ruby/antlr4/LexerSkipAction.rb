require '../antlr4/LexerAction'
require 'singleton'

class LexerSkipAction < LexerAction

  include Singleton

  def getActionType()
    return LexerActionType::SKIP
  end


  def isPositionDependent()
    return false
  end


  def execute(lexer)
    lexer.skip()
  end


  def hash()
    hashcode = 0
    hashcode = MurmurHash.update_int(hashcode, getActionType())
    return MurmurHash.finish(hashcode, 1)
  end


  def eql?(obj)
    return obj == self
  end


  def to_s()
    return "skip"
  end
end
