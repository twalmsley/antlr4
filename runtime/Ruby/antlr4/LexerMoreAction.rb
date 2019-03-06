require '../antlr4/LexerAction'
require 'singleton'

class LexerMoreAction < LexerAction

  include Singleton

  def getActionType()
    return LexerActionType::MORE
  end


  def isPositionDependent()
    return false
  end


  def execute(lexer)
    lexer.more()
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
    return "more"
  end
end
