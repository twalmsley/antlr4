require '../antlr4/LexerDFASerializer'
require '../antlr4/DFASerializer'

class DFA

  attr_accessor :states
  attr_accessor :s0
  attr_reader :decision
  attr_reader :atnStartState

  def initialize(atnStartState, decision = 0)
    @atnStartState = atnStartState
    @decision = decision
    @states = Hash.new

    precedenceDfa = false
    if (atnStartState.is_a? StarLoopEntryState)
      if (atnStartState.isPrecedenceDecision)
        precedenceDfa = true
        precedenceState = DFAState.new(ATNConfigSet.new())
        precedenceState.edges = []
        precedenceState.isAcceptState = false
        precedenceState.requiresFullContext = false
        @s0 = precedenceState
      end
    end

    @precedenceDfa = precedenceDfa
  end


  def isPrecedenceDfa()
    return @precedenceDfa
  end


  def getPrecedenceStartState(precedence)
    if (!isPrecedenceDfa())
      raise IllegalStateException, "Only precedence DFAs may contain a precedence start state."
    end

# s0.edges is never nil for a precedence DFA
    if (precedence < 0 || precedence >= @s0.edges.length)
      return nil
    end

    return @s0.edges[precedence]
  end


  def setPrecedenceStartState(precedence, startState)
    if (!isPrecedenceDfa())
      raise IllegalStateException, "Only precedence DFAs may contain a precedence start state."
    end

    if (precedence < 0)
      return
    end

    @s0.edges[precedence] = startState
  end


  def setPrecedenceDfa(precedenceDfa)
    if (precedenceDfa != isPrecedenceDfa())
      raise UnsupportedOperationException, "The precedenceDfa field cannot change after a DFA is constructed."
    end
  end


  def getStates()
    result = @states.keys
    result.sort! {|i, j| i.stateNumber - j.stateNumber}

    return result
  end


  def to_s()
    return toString(VocabularyImpl.EMPTY_VOCABULARY)
  end


  def to_s_1(tokenNames)
    if (@s0 == nil)
      return ""
    end
    serializer = DFASerializer.new
    serializer.initFromTokenNames(self, tokenNames)
    return serializer.to_s
  end

  def toString(vocabulary)
    if (@s0 == nil)
      return ""
    end

    serializer = DFASerializer.new
    serializer.initFromVocabulary(self, vocabulary)
    return serializer.to_s()
  end

  def toLexerString()
    if (@s0 == nil)
      return ""
    end
    serializer = LexerDFASerializer.new(self)
    return serializer.to_s()
  end

end
