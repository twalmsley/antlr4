require '../antlr4/LexerAction'
require '../antlr4/LexerActionType'

class LexerChannelAction < LexerAction
  attr_reader :channel

  def initialize(channel)
    @channel = channel
  end


  def getActionType()
    return LexerActionType::CHANNEL
  end


  def isPositionDependent()
    return false
  end


  def execute(lexer)
    lexer.setChannel(@channel)
  end


  def hash()
    hashCode = 0
    hashCode = MurmurHash.update_int(hashCode, getActionType().ordinal())
    hashCode = MurmurHash.update_int(hashCode, channel)
    return MurmurHash.finish(hashCode, 2)
  end


  def eql?(obj)
    if (obj == self)
      return true
    else
      if (!(obj.is_a? LexerChannelAction))
        return false
      end
    end

    return @channel == obj.channel
  end


  def to_s()
    return "channel(" << @channel.to_s << ")"
  end
end
