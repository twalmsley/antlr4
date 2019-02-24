require '../antlr4/LL1Analyzer'

class IllegalArgumentException < RuntimeError
end

class ATN

  class << self
    attr_accessor :INVALID_ALT_NUMBER
    @@INVALID_ALT_NUMBER = 0
  end

  attr_accessor :states
  attr_accessor :grammarType
  attr_accessor :ruleToTokenType
  attr_accessor :ruleToStartState
  attr_accessor :ruleToStopState
  attr_accessor :modeNameToStartState
  attr_accessor :modeToStartState
  attr_accessor :decisionToState
  attr_accessor :lexerActions

  def initialize(grammarType, maxTokenType)
    @states = []
    @decisionToState = []
    @ruleToStartState = []
    @ruleToStopState = []
    @modeNameToStartState = Hash.new
    @grammarType = grammarType
    @maxTokenType = maxTokenType
    @ruleToTokenType = []
    @lexerActions = []
    @modeToStartState = []
  end

  def nextTokens_ctx(s, ctx)
    LL1Analyzer.new(self).LOOK(s, ctx)
  end

  def nextTokens(s)
    if s.nextTokenWithinRule != nil
      return s.nextTokenWithinRule
    end
    s.nextTokenWithinRule = nextTokens_ctx(s, nil)
    s.nextTokenWithinRule.setReadonly(true)
    s.nextTokenWithinRule
  end

  def addState(state)
    if (state != nil)
      state.atn = self
      state.stateNumber = @states.length
    end

    @states << state
  end

  def removeState(state)
    @states[state.stateNumber] = nil
  end

  def defineDecisionState(s)
    @decisionToState << s
    s.decision = @decisionToState.length - 1
  end

  def getDecisionState(decision)
    if !@decisionToState.empty?
      return @decisionToState[decision]
    end
  end

  def getNumberOfDecisions
    @decisionToState.length
  end


  def getExpectedTokens(stateNumber, context)
    if stateNumber < 0 || stateNumber >= @states.length
      raise IllegalArgumentException, "Invalid state number."
    end

    ctx = context
    s = @states[stateNumber]
    following = self.nextTokens(s)
    if !following.contains(Token::EPSILON)
      return following
    end

    expected = IntervalSet.new
    expected.concat(following)
    expected.delete(Token::EPSILON)
    while ctx != nil && ctx.invokingState >= 0 && following.include?(Token::EPSILON)
      invokingState = @states[ctx.invokingState]
      rt = invokingState.transition(0)
      following = self.nextTokens(rt.followState)
      expected.addAll(following)
      expected.remove(Token::EPSILON)
      ctx = ctx.parent
    end

    if following.include?(Token::EPSILON)
      expected << Token::EOF
    end

    expected
  end
end

