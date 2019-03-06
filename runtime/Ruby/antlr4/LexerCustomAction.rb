require '../antlr4/LexerAction'
require '../antlr4/LexerActionType'

class LexerCustomAction < LexerAction
  attr_reader :ruleIndex
  attr_reader :actionIndex

  def initialize(ruleIndex, actionIndex)
    @ruleIndex = ruleIndex
    @actionIndex = actionIndex
  end

  def getActionType()
    return LexerActionType::CUSTOM
  end


  def isPositionDependent()
    return true
  end


  def execute(lexer)
    lexer.action(nil, @ruleIndex, @actionIndex)
  end


  def hash()
    hashCode = 0
    hashCode = MurmurHash.update_int(hashCode, getActionType())
    hashCode = MurmurHash.update_int(hashCode, ruleIndex)
    hashCode = MurmurHash.update_(hashCode, actionIndex)
    return MurmurHash.finish(hashCode, 3)
  end


  def eql?(obj)
    if (obj == self)
      return true
    else
      if (!(obj.is_a? LexerCustomAction))
        return false
      end
    end

    return @ruleIndex == obj.ruleIndex && @actionIndex == obj.actionIndex
  end
end
