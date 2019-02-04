require '../../antlr4/runtime/Ruby/antlr4/ATNDeserializer'
require '../../antlr4/runtime/Ruby/antlr4/Integer'
require '../../antlr4/runtime/Ruby/antlr4/DFAState'
require '../../antlr4/runtime/Ruby/antlr4/ATNConfigSet'

class ATNSimulator
  SERIALIZED_VERSION = ATNDeserializer.SERIALIZED_VERSION


  SERIALIZED_UUID = ATNDeserializer.SERIALIZED_Uuid

  attr_accessor :atn

  ERROR = DFAState.new
  ERROR.initializeConfigs(ATNConfigSet.new())
  ERROR.stateNumber = Integer::MAX

  def initialize(atn, sharedContextCache)
    @atn = atn
    @sharedContextCache = sharedContextCache
  end

  def clearDFA()
    raise UnsupportedOperationException, "This ATN simulator does not support clearing the DFA."
  end

  def getSharedContextCache()
    return @sharedContextCache
  end

  def getCachedContext(context)
    if (@sharedContextCache == nil)
      return context
    end

    visited = Hash.new
    return PredictionContext.getCachedContext(context, @sharedContextCache, visited)
  end


  def self.deserialize(data)
    return ATNDeserializer.new().deserialize(data)
  end


  def self.checkCondition(condition, message = nil)
    ATNDeserializer.new().checkCondition(condition, message)
  end


  def self.toInt(c)
    return ATNDeserializer.toInt(c)
  end


  def self.toInt32(data, offset)
    return ATNDeserializer.toInt32(data, offset)
  end


  def self.toLong(data, offset)
    return ATNDeserializer.toLong(data, offset)
  end


  def self.toUUID(data, offset)
    return ATNDeserializer.toUUID(data, offset)
  end


  def edgeFactory(atn, type, src, trg, arg1, arg2, arg3, sets)

    return ATNDeserializer.new().edgeFactory(atn, type, src, trg, arg1, arg2, arg3, sets)
  end


  def stateFactory(type, ruleIndex)
    return ATNDeserializer.new().stateFactory(type, ruleIndex)
  end

end
