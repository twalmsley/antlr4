require '../antlr4/Integer'
require '../antlr4/RuleContext'

class PredictionContext
  INITIAL_HASH = 1
  EMPTY_RETURN_STATE = Integer::MAX

  class << self
    @@globalNodeCount = 0
  end

  attr_accessor :cachedHashCode

  def initialize(cachedHashCode)
    @id = @@globalNodeCount
    @@globalNodeCount += 1
    @cachedHashCode = cachedHashCode
  end


  def size()

  end

  def getParent(index)

  end

  def getReturnState(index)

  end

  def hasEmptyPath()
# since EMPTY_RETURN_STATE can only appear in the last position, we check last one
    return getReturnState(size() - 1) == EMPTY_RETURN_STATE
  end


  def hash()
    return @cachedHashCode
  end


  def equals(obj)

  end

  def to_s_recog(recog)
    return to_s()
  end

  def toStrings(recognizer, currentState)
    return toStrings_3(recognizer, EMPTY, currentState)
  end

  def toStrings_3(recognizer, stop, currentState)
    result = []

    while toStrings_3_inner

    end

    return result.toArray(new String[result.size()])
  end

  def toStrings_3_inner
    perm = 0
    while perm
      offset = 0
      last = true
      p = self
      stateNumber = currentState
      localBuffer = ""
      localBuffer << "["
      while (!p.isEmpty() && p != stop)
        index = 0
        if (p.size() > 0)
          bits = 1
          while ((1 << bits) < p.size())
            bits += 1
          end

          mask = (1 << bits) - 1
          index = (perm >> offset) & mask
          last &= index >= p.size() - 1
          if (index >= p.size())
            return true
          end
          offset += bits
        end

        if (recognizer != nil)
          if (localBuffer.length() > 1)
            # first char is '[', if more than that this isn't the first rule
            localBuffer << ' '
          end

          atn = recognizer.getATN()
          s = atn.states.get(stateNumber)
          ruleName = recognizer.getRuleNames()[s.ruleIndex]
          localBuffer << ruleName
        elsif (p.getReturnState(index) != EMPTY_RETURN_STATE)
          if (!p.isEmpty())
            if (localBuffer.length() > 1)
              # first char is '[', if more than that this isn't the first rule
              localBuffer << ' '
            end

            localBuffer << p.getReturnState(index)
          end
        end
        stateNumber = p.getReturnState(index)
        p = p.getParent(index)
      end
      localBuffer << "]"
      result.push(localBuffer.to_s())

      if (last)
        break
      end
      perm += 1
    end
    return false
  end

end

