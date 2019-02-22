require 'ostruct'
require '../../antlr4/runtime/Ruby/antlr4/ATNDeserializationOptions'
require '../../antlr4/runtime/Ruby/antlr4/Uuid'
require '../../antlr4/runtime/Ruby/antlr4/ATNType'
require '../../antlr4/runtime/Ruby/antlr4/ATNState'
require '../../antlr4/runtime/Ruby/antlr4/ATN'
require '../../antlr4/runtime/Ruby/antlr4/BlockStartState'
require '../../antlr4/runtime/Ruby/antlr4/Transition'

require '../../antlr4/runtime/Ruby/antlr4/BasicState'
require '../../antlr4/runtime/Ruby/antlr4/RuleStartState'
require '../../antlr4/runtime/Ruby/antlr4/BasicBlockStartState'
require '../../antlr4/runtime/Ruby/antlr4/PlusBlockStartState'
require '../../antlr4/runtime/Ruby/antlr4/StarBlockStartState'
require '../../antlr4/runtime/Ruby/antlr4/TokensStartState'
require '../../antlr4/runtime/Ruby/antlr4/RuleStopState'
require '../../antlr4/runtime/Ruby/antlr4/BlockEndState'
require '../../antlr4/runtime/Ruby/antlr4/StarLoopbackState'
require '../../antlr4/runtime/Ruby/antlr4/StarLoopEntryState'
require '../../antlr4/runtime/Ruby/antlr4/PlusLoopbackState'
require '../../antlr4/runtime/Ruby/antlr4/LoopEndState'

require '../../antlr4/runtime/Ruby/antlr4/EpsilonTransition'
require '../../antlr4/runtime/Ruby/antlr4/RangeTransition'
require '../../antlr4/runtime/Ruby/antlr4/RangeTransition'
require '../../antlr4/runtime/Ruby/antlr4/RuleTransition'
require '../../antlr4/runtime/Ruby/antlr4/PredicateTransition'
require '../../antlr4/runtime/Ruby/antlr4/PrecedencePredicateTransition'
require '../../antlr4/runtime/Ruby/antlr4/AtomTransition'
require '../../antlr4/runtime/Ruby/antlr4/ActionTransition'
require '../../antlr4/runtime/Ruby/antlr4/SetTransition'
require '../../antlr4/runtime/Ruby/antlr4/NotSetTransition'
require '../../antlr4/runtime/Ruby/antlr4/WildcardTransition'

class UnsupportedOperationException < StandardError
end

class IllegalStateException < StandardError
end

class ATNDeserializer
  @@SERIALIZED_VERSION = 3
  @@BASE_SERIALIZED_Uuid = Uuid.fromString("33761B2D-78BB-4A43-8B0B-4F5BEE8AACF3")
  @@ADDED_PRECEDENCE_TRANSITIONS = Uuid.fromString("1DA0C57D-6C06-438A-9B27-10BCB3CE0F61")
  @@ADDED_LEXER_ACTIONS = Uuid.fromString("AADB8D7E-AEEF-4415-AD2B-8204D6CF042E")
  @@ADDED_UNICODE_SMP = Uuid.fromString("59627784-3BE5-417A-B9EB-8131A7286089")
  @@SUPPORTED_UuidS = [@@BASE_SERIALIZED_Uuid, @@ADDED_PRECEDENCE_TRANSITIONS, @@ADDED_LEXER_ACTIONS, @@ADDED_UNICODE_SMP]

  @@SERIALIZED_Uuid = @@ADDED_UNICODE_SMP


  class << self
    attr_accessor :SERIALIZED_Uuid
    attr_accessor :SERIALIZED_VERSION
  end

  class UnicodeDeserializer
    def readUnicode(data, p)
      data[p]
    end

    def size()
      return 1
    end
  end

  class UnicodeDeserializingMode
    UNICODE_BMP = 1
    UNICODE_SMP = 2
  end

  def self.getUnicodeDeserializer(mode)
    if (mode == UnicodeDeserializingMode::UNICODE_BMP)
      return UnicodeDeserializer.new()
    else
      return UnicodeDeserializer.new()
    end
  end

  def initialize(deserializationOptions = nil)
    if (deserializationOptions == nil)
      @deserializationOptions = ATNDeserializationOptions.getDefaultOptions()
    else
      @deserializationOptions = deserializationOptions
    end

  end

  def isFeatureSupported(feature, actualUuid)
    featureIndex = @@SUPPORTED_UuidS.index(feature)
    if (featureIndex < 0)
      return false
    end

    return @@SUPPORTED_UuidS.index(actualUuid) >= featureIndex
  end

  def deserialize(serializedData)
    data = serializedData.codepoints

    i = 1
    while i < data.length
      data[i] = data[i] - 2
      i += 1
    end

    p = 0
    version = data[p]
    p += 1
    if (version != @@SERIALIZED_VERSION)
      reason = sprintf "Could not deserialize ATN with version %d (expected %d).\n" % [version, @@SERIALIZED_VERSION]
      raise UnsupportedOperationException, reason
    end

    uuid = toUuid(data, p)
    p += 8
    if (!@@SUPPORTED_UuidS.include?(uuid))
      reason = sprintf "Could not deserialize ATN with Uuid %s (expected %s or a legacy Uuid).\n" % [uuid, @@SERIALIZED_Uuid]
      raise UnsupportedOperationException, reason
    end

    supportsPrecedencePredicates = isFeatureSupported(@@ADDED_PRECEDENCE_TRANSITIONS, uuid)
    supportsLexerActions = isFeatureSupported(@@ADDED_LEXER_ACTIONS, uuid)

    grammarType = ATNType.values[data[p]]
    p += 1
    maxTokenType = data[p]
    p += 1
    atn = ATN.new(grammarType, maxTokenType)

    loopBackStateNumbers = []
    endStateNumbers = []
    nstates = data[p]
    p += 1
    i = 0
    while i < nstates
      stype = data[p]
      p += 1
      if stype == ATNState::INVALID_TYPE
        atn.addState(nil)
        i += 1
        next
      end

      ruleIndex = data[p]
      p += 1
      if (ruleIndex == 0xFFFF)
        ruleIndex = -1
      end

      s = stateFactory(stype, ruleIndex)
      if (stype == ATNState::LOOP_END)
        loopBackStateNumber = data[p]
        p += 1
        pair = OpenStruct.new
        pair.a = s
        pair.b = loopBackStateNumber
        loopBackStateNumbers << pair
      elsif s.is_a? BlockStartState
        endStateNumber = data[p]
        p += 1
        pair = OpenStruct.new
        pair.a = s
        pair.b = endStateNumber
        endStateNumbers << pair
      end
      atn.addState(s)
      i += 1
    end

    loopBackStateNumbers.each do |pair|
      pair.a.loopBackState = atn.states[pair.b]
    end

    endStateNumbers.each do |pair|
      pair.a.endState = atn.states[pair.b]
    end

    numNonGreedyStates = data[p]
    p += 1
    i = 0
    while i < numNonGreedyStates
      stateNumber = data[p]
      p += 1
      atn.states[stateNumber].nonGreedy = true
      i += 1
    end

    if (supportsPrecedencePredicates)
      numPrecedenceStates = data[p]
      p += 1
      i = 0
      while i < numPrecedenceStates
        stateNumber = data[p]
        p += 1
        atn.states[stateNumber].isLeftRecursiveRule = true
        i += 1
      end
    end

    nrules = data[p]
    p += 1
    if (atn.grammarType == ATNType::LEXER)
      atn.ruleToTokenType = []
    end

    atn.ruleToStartState = []
    i = 0
    while i < nrules
      s = data[p]
      p += 1
      startState = atn.states[s]
      atn.ruleToStartState[i] = startState
      if (atn.grammarType == ATNType::LEXER)
        tokenType = data[p]
        p += 1
        if (tokenType == 0xFFFF)
          tokenType = Token::EOF
        end

        atn.ruleToTokenType[i] = tokenType

        if (!isFeatureSupported(@@ADDED_LEXER_ACTIONS, uuid))
          @actionIndexIgnored = data[p]
          p += 1
        end
      end
      i += 1
    end

    atn.ruleToStopState = []
    atn.states.each do |state|
      if (!(state.is_a? RuleStopState))
        next
      end

      stopState = state
      atn.ruleToStopState[state.ruleIndex] = stopState
      atn.ruleToStartState[state.ruleIndex].stopState = stopState
    end


    nmodes = data[p]
    p += 1
    i = 0
    while i < nmodes
      s = data[p]
      p += 1
      atn.modeToStartState << atn.states[s]
      i += 1
    end

    sets = []

    p = deserializeSets(data, p, sets, ATNDeserializer.getUnicodeDeserializer(UnicodeDeserializingMode::UNICODE_BMP))

    if (isFeatureSupported(@@ADDED_UNICODE_SMP, uuid))
      p = deserializeSets(data, p, sets, ATNDeserializer.getUnicodeDeserializer(UnicodeDeserializingMode::UNICODE_SMP))
    end

    nedges = data[p]
    p += 1
    i = 0
    while i < nedges
      src = data[p]
      trg = data[p + 1]
      ttype = data[p + 2]
      arg1 = data[p + 3]
      arg2 = data[p + 4]
      arg3 = data[p + 5]
      trans = edgeFactory(atn, ttype, src, trg, arg1, arg2, arg3, sets)
      srcState = atn.states[src]
      srcState.addTransition(trans)
      p += 6
      i += 1
    end

    atn.states.each do |state|
      i = 0
      while i < state.getNumberOfTransitions()
        t = state.transition(i)
        if (!(t.is_a? RuleTransition))
          i += 1
          next
        end

        ruleTransition = t
        outermostPrecedenceReturn = -1
        if (atn.ruleToStartState[ruleTransition.target.ruleIndex].isLeftRecursiveRule)
          if (ruleTransition.precedence == 0)
            outermostPrecedenceReturn = ruleTransition.target.ruleIndex
          end
        end

        returnTransition = EpsilonTransition.new(ruleTransition.followState, outermostPrecedenceReturn)
        atn.ruleToStopState[ruleTransition.target.ruleIndex].addTransition(returnTransition)
        i += 1
      end
    end

    atn.states.each do |state|
      if (state.is_a? BlockStartState)
        if (state.endState == nil)
          raise IllegalStateException
        end

        if (state.endState.startState != nil)
          raise IllegalStateException
        end

        state.endState.startState = state
      end

      if (state.is_a? PlusLoopbackState)
        loopbackState = state
        i = 0
        while i < loopbackState.getNumberOfTransitions()
          target = loopbackState.transition(i).target
          if (target.is_a? PlusBlockStartState)
            target.loopBackState = loopbackState
          end
          i += 1
        end
      elsif (state.is_a? StarLoopbackState)
        loopbackState = state
        i = 0
        while i < loopbackState.getNumberOfTransitions()
          target = loopbackState.transition(i).target
          if (target.is_a? StarLoopEntryState)
            target.loopBackState = loopbackState
          end
          i += 1
        end
      end
    end

    ndecisions = data[p]
    p += 1
    i = 1
    while i <= ndecisions
      s = data[p]
      p += 1
      decState = atn.states[s]
      atn.decisionToState << decState
      decState.decision = i - 1
      i += 1
    end

    if (atn.grammarType == ATNType::LEXER)
      if (supportsLexerActions)
        atn.lexerActions = []
        p += 1
        i = 0
        while i < atn.lexerActions.length
          actionType = LexerActionType.values()[data[p]]
          p += 1
          data1 = data[p]
          p += 1
          if (data1 == 0xFFFF)
            data1 = -1
          end

          data2 = data[p]
          p += 1
          if (data2 == 0xFFFF)
            data2 = -1
          end

          lexerAction = lexerActionFactory(actionType, data1, data2)

          atn.lexerActions[i] = lexerAction
          i += 1
        end
      else
        legacyLexerActions = []
        atn.states.each do |state|
          i = 0
          while i < state.getNumberOfTransitions()
            transition = state.transition(i)
            if (!(transition.is_a? ActionTransition))
              next
            end

            ruleIndex = (transition).ruleIndex
            actionIndex = (transition).actionIndex
            lexerAction = LexerCustomAction.new(ruleIndex, actionIndex)
            state.setTransition(i, ActionTransition.new(transition.target, ruleIndex, legacyLexerActions.length, false))
            legacyLexerActions << lexerAction
            i += 1
          end
        end

        atn.lexerActions = legacyLexerActions
      end
    end

    markPrecedenceDecisions(atn)

    if (@deserializationOptions.isVerifyATN())
      verifyATN(atn)
    end

    if (@deserializationOptions.isGenerateRuleBypassTransitions() && atn.grammarType == ATNType.PARSER)
      atn.ruleToTokenType = []
      i = 0
      while i < atn.ruleToStartState.length
        atn.ruleToTokenType[i] = atn.maxTokenType + i + 1
        i += 1
      end

      i = 0
      while i < atn.ruleToStartState.length
        bypassStart = BasicBlockStartState.new
        bypassStart.ruleIndex = i
        atn.addState(bypassStart)

        bypassStop = BlockEndState.new
        bypassStop.ruleIndex = i
        atn.addState(bypassStop)

        bypassStart.endState = bypassStop
        atn.defineDecisionState(bypassStart)

        bypassStop.startState = bypassStart

        endState = nil
        excludeTransition = nil
        if (atn.ruleToStartState[i].isLeftRecursiveRule)
          endState = nil
          atn.states.each do |state|
            if (state.ruleIndex != i)
              next
            end

            if (!(state.is_a? StarLoopEntryState))
              next
            end

            maybeLoopEndState = state.transition(state.getNumberOfTransitions() - 1).target
            if (!(maybeLoopEndState.is_a? LoopEndState))
              next
            end

            if (maybeLoopEndState.epsilonOnlyTransitions && maybeLoopEndState.transition(0).target.is_a?(RuleStopState))
              endState = state
              break
            end
          end

          if (endState == nil)
            raise UnsupportedOperationException, "Couldn't identify final state of the precedence rule prefix section."
          end

          excludeTransition = endState.loopBackState.transition(0)
        else
          endState = atn.ruleToStopState[i]
        end

        atn.states.each do |state|
          state.transitions.each do |transition|
            if (transition == excludeTransition)
              next
            end

            if (transition.target == endState)
              transition.target = bypassStop
            end
          end
        end

        while (atn.ruleToStartState[i].getNumberOfTransitions() > 0)
          transition = atn.ruleToStartState[i].removeTransition(atn.ruleToStartState[i].getNumberOfTransitions() - 1)
          bypassStart.addTransition(transition)
        end

        atn.ruleToStartState[i].addTransition(new EpsilonTransition(bypassStart))
        bypassStop.addTransition(new EpsilonTransition(endState))

        matchState = BasicState.new
        atn.addState(matchState)
        matchState.addTransition(AtomTransition.new(bypassStop, atn.ruleToTokenType[i]))
        bypassStart.addTransition(EpsilonTransition.new(matchState))
      end

      if (deserializationOptions.isVerifyATN())
        verifyATN(atn)
      end
    end

    return atn
  end

  def deserializeSets(data, p, sets, unicodeDeserializer)
    nsets = data[p]
    p += 1
    i = 0
    while i < nsets
      nintervals = data[p]
      p += 1
      set = IntervalSet.new
      sets << set

      containsEof = data[p] != 0
      p += 1
      if (containsEof)
        set.add(-1)
      end

      j = 0
      while j < nintervals
        a = unicodeDeserializer.readUnicode(data, p)
        p += unicodeDeserializer.size
        b = unicodeDeserializer.readUnicode(data, p)
        p += unicodeDeserializer.size
        set.add(a, b)
        j += 1
      end
      i += 1
    end
    return p
  end

  def markPrecedenceDecisions(atn)
    atn.states.each do |state|
      if (!(state.is_a? StarLoopEntryState))
        next
      end

      if (atn.ruleToStartState[state.ruleIndex].isLeftRecursiveRule)
        maybeLoopEndState = state.transition(state.getNumberOfTransitions() - 1).target
        if (maybeLoopEndState.is_a? LoopEndState)
          if (maybeLoopEndState.epsilonOnlyTransitions && maybeLoopEndState.transition(0).target.is_a?(RuleStopState))
            state.isPrecedenceDecision = true
          end
        end
      end
    end
  end

  def verifyATN(atn)
    atn.states.each do |state|
      if (state == nil)
        next
      end

      checkCondition(state.onlyHasEpsilonTransitions() || state.getNumberOfTransitions() <= 1)

      if (state.is_a? PlusBlockStartState)
        checkCondition(state.loopBackState != nil)
      end

      if (state.is_a? StarLoopEntryState)
        starLoopEntryState = state
        checkCondition(starLoopEntryState.loopBackState != nil)
        checkCondition(starLoopEntryState.getNumberOfTransitions() == 2)

        if (starLoopEntryState.transition(0).target.is_a? StarBlockStartState)
          checkCondition(starLoopEntryState.transition(1).target.is_a? LoopEndState)
          checkCondition(!starLoopEntryState.nonGreedy)
        elsif (starLoopEntryState.transition(0).target.is_a? LoopEndState)
          checkCondition(starLoopEntryState.transition(1).target.is_a? StarBlockStartState)
          checkCondition(starLoopEntryState.nonGreedy)
        else
          raise IllegalStateException
        end
      end

      if (state.is_a? StarLoopbackState)
        checkCondition(state.getNumberOfTransitions() == 1)
        checkCondition(state.transition(0).target.is_a? StarLoopEntryState)
      end

      if (state.is_a? LoopEndState)
        checkCondition(state.loopBackState != nil)
      end

      if (state.is_a? RuleStartState)
        checkCondition(state.stopState != nil)
      end

      if (state.is_a? BlockStartState)
        checkCondition(state.endState != nil)
      end

      if (state.is_a? BlockEndState)
        checkCondition(state.startState != nil)
      end

      if (state.is_a? DecisionState)
        decisionState = state
        checkCondition(decisionState.getNumberOfTransitions() <= 1 || decisionState.decision >= 0)
      else
        checkCondition(state.getNumberOfTransitions() <= 1 || state.is_a?(RuleStopState))
      end
    end
  end

  def checkCondition(condition, message = nil)
    if (!condition)
      raise IllegalStateException, message
    end
  end

  def toInt32(data, offset)
    return data[offset] | (data[offset + 1] << 16)
  end

  def toLong(data, offset)
    lowOrder = toInt32(data, offset) & 0x00000000FFFFFFFF
    return lowOrder | (toInt32(data, offset + 2) << 32)
  end

  def toUuid(data, offset)
    leastSigBits = toLong(data, offset)
    mostSigBits = toLong(data, offset + 4)
    return Uuid.new(mostSigBits, leastSigBits)
  end


  def edgeFactory(atn,
                  type, src, trg,
                  arg1, arg2, arg3,
                  sets)

    target = atn.states[trg]
    case (type)
    when Transition::EPSILON
      return EpsilonTransition.new(target)
    when Transition::RANGE
      if (arg3 != 0)
        return RangeTransition.new(target, Token::EOF, arg2)
      else
        return RangeTransition.new(target, arg1, arg2)
      end
    when Transition::RULE
      rt = RuleTransition.new(atn.states[arg1], arg2, arg3, target)
      return rt
    when Transition::PREDICATE
      pt = PredicateTransition.new(target, arg1, arg2, arg3 != 0)
      return pt
    when Transition::PRECEDENCE
      return PrecedencePredicateTransition.new(target, arg1)
    when Transition::ATOM
      if (arg3 != 0)
        return AtomTransition.new(target, Token::EOF)
      else
        return AtomTransition.new(target, arg1)
      end
    when Transition::ACTION
      a = ActionTransition.new(target, arg1, arg2, arg3 != 0)
      return a
    when Transition::SET
      return SetTransition.new(target, sets[arg1])
    when Transition::NOT_SET
      return NotSetTransition.new(target, sets[arg1])
    when Transition::WILDCARD
      return WildcardTransition.new(target)
    else
      raise IllegalArgumentException, " The specified transition type is not valid."
    end
  end

  def stateFactory(type, ruleIndex)
    s = nil
    case (type)
    when ATNState::INVALID_TYPE
      return nil
    when ATNState::BASIC
      s = BasicState.new
    when ATNState::RULE_START
      s = RuleStartState.new
    when ATNState::BLOCK_START
      s = BasicBlockStartState.new
    when ATNState::PLUS_BLOCK_START
      s = PlusBlockStartState.new
    when ATNState::STAR_BLOCK_START
      s = StarBlockStartState.new
    when ATNState::TOKEN_START
      s = TokensStartState.new
    when ATNState::RULE_STOP
      s = RuleStopState.new
    when ATNState::BLOCK_END
      s = BlockEndState.new
    when ATNState::STAR_LOOP_BACK
      s = StarLoopbackState.new
    when ATNState::STAR_LOOP_ENTRY
      s = StarLoopEntryState.new
    when ATNState::PLUS_LOOP_BACK
      s = PlusLoopbackState.new
    when ATNState::LOOP_END
      s = LoopEndState.new
    else
      message = sprintf " The specified state type % d is not valid.\n" % [type]
      raise IllegalArgumentException, message
    end
    s.ruleIndex = ruleIndex
    return s
  end


  def lexerActionFactory(type, data1, data2)
    case (type)
    when LexerActionType::CHANNEL
      return LexerChannelAction.new(data1)

    when LexerActionType::CUSTOM
      return LexerCustomAction.new(data1, data2)

    when LexerActionType::MODE
      return LexerModeAction.new(data1)

    when LexerActionType::MORE
      return LexerMoreAction.INSTANCE

    when LexerActionType::POP_MODE
      return LexerPopModeAction.INSTANCE

    when LexerActionType::PUSH_MODE
      return LexerPushModeAction.new(data1)

    when LexerActionType::SKIP
      return LexerSkipAction.INSTANCE

    when LexerActionType::TYPE
      return LexerTypeAction.new(data1)

    else
      message = sprintf " The specified lexer action type % d is not valid.\n" % [type]
      raise IllegalArgumentException, message
    end
  end
end
