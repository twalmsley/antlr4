require '../antlr4/ATNSimulator'
require '../antlr4/EmptyPredictionContext'
require '../antlr4/Integer'
require '../antlr4/LexerATNConfig'
require '../antlr4/OrderedATNConfigSet'

class LexerATNSimulator < ATNSimulator

  MIN_DFA_EDGE = 0
  MAX_DFA_EDGE = 127 # forces unicode to stay in ATN

  EMPTY = EmptyPredictionContext.new(Integer::MAX)

  class SimState
    attr_accessor :index
    attr_accessor :line
    attr_accessor :charPos
    attr_accessor :dfaState

    def reset()
      @index = -1
      @line = 0
      @charPos = -1
      @dfaState = nil
    end
  end


  def initialize(recog, atn, decisionToDFA, sharedContextCache)
    super(atn, sharedContextCache)
    @debug = false
    @dfa_debug = false

    @decisionToDFA = decisionToDFA
    @recog = recog
    @startIndex = -1
    @line = 1
    @charPositionInLine = 0
    @mode = Lexer::DEFAULT_MODE
    @prevAccept = SimState.new
    @match_calls = 0
  end

  def copyState(simulator)
    @charPositionInLine = simulator.charPositionInLine
    @line = simulator.line
    @mode = simulator.mode
    @startIndex = simulator.startIndex
  end

  def match(input, mode)
    @match_calls += 1
    @mode = mode
    mark = input.mark()

    begin
      @startIndex = input.index()
      @prevAccept.reset()
      dfa = @decisionToDFA[mode]
      if (dfa.s0 == nil)
        return matchATN(input)
      else
        return execATN(input, dfa.s0)
      end
    ensure
      input.release(mark)
    end
  end


  def reset()
    @prevAccept.reset()
    @startIndex = -1
    @line = 1
    @charPositionInLine = 0
    @mode = Lexer.DEFAULT_MODE
  end


  def clearDFA()
    d = 0
    while d < @decisionToDFA.length
      @decisionToDFA[d] = DFA.new(atn.getDecisionState(d), d)
      d += 1
    end
  end

  def matchATN(input)
    startState = atn.modeToStartState[@mode]

    if (@debug)
      printf "matchATN mode %d start: %s\n" % [@mode, startState]
    end

    old_mode = @mode

    s0_closure = computeStartState(input, startState)
    suppressEdge = s0_closure.hasSemanticContext
    s0_closure.hasSemanticContext = false

    nextState = addDFAState(s0_closure)
    if (!suppressEdge)
      @decisionToDFA[@mode].s0 = nextState
    end

    predict = execATN(input, nextState)

    if (@debug)
      printf "DFA after matchATN: %s\n" % [@decisionToDFA[old_mode].toLexerString()]
    end

    return predict
  end

  def execATN(input, ds0)
    if (@debug)
      printf "start state closure=%s\n" % [ds0.configs]
    end

    if (ds0.isAcceptState)
      # allow zero-length tokens
      captureSimState(@prevAccept, input, ds0)
    end

    t = input.LA(1)

    s = ds0 # s is current/from DFA state

    while (true) # while more work
      if (@debug)
        printf "execATN loop starting closure: %s\n" % [s.configs]
      end

      # As we move src->trg, src->trg, we keep track of the previous trg to
      # avoid looking up the DFA state again, which is expensive.
      # If the previous target was already part of the DFA, we might
      # be able to avoid doing a reach operation upon t. If s!=nil,
      # it means that semantic predicates didn't prevent us from
      # creating a DFA state. Once we know s!=nil, we check to see if
      # the DFA state has an edge already for t. If so, we can just reuse
      # it's configuration set there's no point in re-computing it.
      # This is kind of like doing DFA simulation within the ATN
      # simulation because DFA simulation is really just a way to avoid
      # computing reach/closure sets. Technically, once we know that
      # we have a previously added DFA state, we could jump over to
      # the DFA simulator. But, that would mean popping back and forth
      # a lot and making things more complicated algorithmically.
      # This optimization makes a lot of sense for loops within DFA.
      # A character will take us back to an existing DFA state
      # that already has lots of edges out of it. e.g., .* in comments.
      target = getExistingTargetState(s, t)
      if (target == nil)
        target = computeTargetState(input, s, t)
      end

      if (target == ERROR)
        break
      end

      # If this is a consumable input element, make sure to consume before
      # capturing the accept state so the input index, line, and char
      # position accurately reflect the state of the interpreter at the
      # end of the token.
      if (t != IntStream::EOF)
        consume(input)
      end

      if (target.isAcceptState)
        captureSimState(@prevAccept, input, target)
        if (t == IntStream::EOF)
          break
        end
      end

      t = input.LA(1)
      s = target # flip current DFA target becomes new src/from state
    end

    return failOrAccept(@prevAccept, input, s.configs, t)
  end


  def getExistingTargetState(s, t)
    if (s.edges == nil || t < MIN_DFA_EDGE || t > MAX_DFA_EDGE)
      return nil
    end

    target = s.edges[t - MIN_DFA_EDGE]
    if (@debug && target != nil)
      puts "reuse state " + s.stateNumber.to_s + " edge to " + target.stateNumber.to_s
    end

    return target
  end


  def computeTargetState(input, s, t)
    reach = OrderedATNConfigSet.new()

# if we don't find an existing DFA state
# Fill reach starting from closure, following t transitions
    getReachableConfigSet(input, s.configs, reach, t)

    if (reach.empty?) # we got nowhere on t from s
      if (!reach.hasSemanticContext)
        # we got nowhere on t, don't throw out this knowledge it'd
        # cause a failover from DFA later.
        addDFAEdge_dfastate_dfastate(s, t, ERROR)
      end

      # stop when we can't match any more char
      return ERROR
    end

# Add an edge from s to target DFA found/created for reach
    return addDFAEdge_dfastate_atnconfigset(s, t, reach)
  end

  def failOrAccept(prevAccept, input, reach, t)

    if (prevAccept.dfaState != nil)
      lexerActionExecutor = prevAccept.dfaState.lexerActionExecutor
      accept(input, lexerActionExecutor, @startIndex,
             prevAccept.index, prevAccept.line, prevAccept.charPos)
      return prevAccept.dfaState.prediction
    else
# if no accept and EOF is first char, return EOF
      if (t == IntStream::EOF && input.index() == @startIndex)
        return Token::EOF
      end

      raise LexerNoViableAltException, @recog
    end
  end


  def getReachableConfigSet(input, closure, reach, t)
# this is used to skip processing for configs which have a lower priority
# than a config that already reached an accept state for the same rule
    skipAlt = ATN::INVALID_ALT_NUMBER
    closure.configs.each do |c|
      currentAltReachedAcceptState = (c.alt == skipAlt)
      if (currentAltReachedAcceptState && c.passedThroughNonGreedyDecision)
        next
      end

      if (@debug)
        printf "testing %s at %s\n" % [getTokenName(t), c.toString_2(@recog, true)]
      end

      n = c.state.getNumberOfTransitions()
      ti = 0
      while ti < n # for each transition
        trans = c.state.transition(ti)
        target = getReachableTarget(trans, t)
        if (target != nil)
          lexerActionExecutor = c.lexerActionExecutor
          if (lexerActionExecutor != nil)
            lexerActionExecutor = lexerActionExecutor.fixOffsetBeforeMatch(input.index() - startIndex)
          end

          treatEofAsEpsilon = (t == CharStream::EOF)
          cfg = LexerATNConfig.new
          cfg.LexerATNConfig_4(c, target, lexerActionExecutor)
          if (closure(input, cfg, reach, currentAltReachedAcceptState, true, treatEofAsEpsilon))
            # any remaining configs for this alt have a lower priority than
            # the one that just reached an accept state.
            skipAlt = c.alt
            break
          end
        end
        ti += 1
      end
    end
  end

  def accept(input, lexerActionExecutor, startIndex, index, line, charPos)

    if (@debug)
      printf "ACTION %s\n" % [lexerActionExecutor]
    end

# seek to after last char in token
    input.seek(index)
    @line = line
    @charPositionInLine = charPos

    if (lexerActionExecutor != nil && @recog != nil)
      lexerActionExecutor.execute(@recog, input, startIndex)
    end
  end


  def getReachableTarget(trans, t)
    if (trans.matches(t, Lexer::MIN_CHAR_VALUE, Lexer::MAX_CHAR_VALUE))
      return trans.target
    end

    return nil
  end


  def computeStartState(input, p)

    initialContext = EMPTY
    configs = ATNConfigSet.new()
    i = 0
    while i < p.getNumberOfTransitions()
      target = p.transition(i).target
      c = LexerATNConfig.new
      c.LexerATNConfig_1(target, i + 1, initialContext)
      closure(input, c, configs, false, false, false)
      i += 1
    end
    return configs
  end


  def closure(input, config, configs, currentAltReachedAcceptState, speculative, treatEofAsEpsilon)

    if (config.state.is_a? RuleStopState)
      if (@debug)
        if (@recog != nil)
          printf "closure at %s rule stop %s\n" % [@recog.getRuleNames()[config.state.ruleIndex], config]
        else
          printf "closure at rule stop %s\n" % [config]
        end
      end

      if (config.context == nil || config.context.hasEmptyPath())
        if (config.context == nil || config.context.isEmpty())
          configs.add(config)
          return true
        else
          configs.add(LexerATNConfig.create_from_config2(config, config.state, EmptyPredictionContext::EMPTY))
          currentAltReachedAcceptState = true
        end
      end

      if (config.context != nil && !config.context.isEmpty())
        i = 0
        while i < config.context.size()
          if (config.context.getReturnState(i) != PredictionContext::EMPTY_RETURN_STATE)
            newContext = config.context.getParent(i) # "pop" return state
            returnState = atn.states[config.context.getReturnState(i)]
            c = LexerATNConfig.new
            c.LexerATNConfig_5(config, returnState, newContext)
            currentAltReachedAcceptState = closure(input, c, configs, currentAltReachedAcceptState, speculative, treatEofAsEpsilon)
          end
          i += 1
        end
      end

      return currentAltReachedAcceptState
    end

# optimization
    if (!config.state.onlyHasEpsilonTransitions())
      if (!currentAltReachedAcceptState || !config.hasPassedThroughNonGreedyDecision())
        configs.add(config)
      end
    end

    p = config.state
    i = 0
    while i < p.getNumberOfTransitions()
      t = p.transition(i)
      c = getEpsilonTarget(input, config, t, configs, speculative, treatEofAsEpsilon)
      if (c != nil)
        currentAltReachedAcceptState = closure(input, c, configs, currentAltReachedAcceptState, speculative, treatEofAsEpsilon)
      end
      i += 1
    end

    return currentAltReachedAcceptState
  end

# side-effect: can alter configs.hasSemanticContext

  def getEpsilonTarget(input, config, t, configs, speculative, treatEofAsEpsilon)

    c = nil
    case (t.getSerializationType())
    when Transition::RULE
      ruleTransition = t
      newContext = SingletonPredictionContext.new(config.context, ruleTransition.followState.stateNumber)
      c = LexerATNConfig.new
      c.LexerATNConfig_5(config, t.target, newContext)


    when Transition::PRECEDENCE

      raise UnsupportedOperationException, "Precedence predicates are not supported in lexers."

    when Transition::PREDICATE
      pt = t
      if (@debug)
        puts("EVAL rule " + pt.ruleIndex + ":" + pt.predIndex)
      end
      configs.hasSemanticContext = true
      if (evaluatePredicate(input, pt.ruleIndex, pt.predIndex, speculative))
        c = LexerATNConfig.create_from_config(config, t.target)
      end

    when Transition::ACTION

      if (config.context == nil || config.context.hasEmptyPath())
        # execute actions anywhere in the start rule for a token.
        #
        # TODO: if the entry rule is invoked recursively, some
        # actions may be executed during the recursive call. The
        # problem can appear when hasEmptyPath() is true but
        # isEmpty() is false. In this case, the config needs to be
        # split into two contexts - one with just the empty path
        # and another with everything but the empty path.
        # Unfortunately, the current algorithm does not allow
        # getEpsilonTarget to return two configurations, so
        # additional modifications are needed before we can support
        # the split operation.
        lexerActionExecutor = LexerActionExecutor.append(config.getLexerActionExecutor(), atn.lexerActions[t.actionIndex])
        c = new LexerATNConfig(config, t.target, lexerActionExecutor)
      else
        # ignore actions in referenced rules
        c = new LexerATNConfig(config, t.target)
      end

    when Transition::EPSILON
      c = LexerATNConfig.new
      c.LexerATNConfig_3(config, t.target)
    when Transition::ATOM, Transition::RANGE, Transition::SET
      if (treatEofAsEpsilon)
        if (t.matches(CharStream.EOF, Lexer.MIN_CHAR_VALUE, Lexer.MAX_CHAR_VALUE))
          c = LexerATNConfig.create_from_config(config, t.target)
        end
      end

    end

    return c
  end


  def evaluatePredicate(input, ruleIndex, predIndex, speculative)
# assume true if no recognizer was provided
    if (@recog == nil)
      return true
    end

    if (!speculative)
      return @recog.sempred(nil, ruleIndex, predIndex)
    end

    savedCharPositionInLine = @charPositionInLine
    savedLine = @line
    index = input.index()
    marker = input.mark()
    begin
      consume(input)
      return @recog.sempred(nil, ruleIndex, predIndex)
    ensure
      @charPositionInLine = savedCharPositionInLine
      @line = savedLine
      input.seek(index)
      input.release(marker)
    end
  end

  def captureSimState(settings, input, dfaState)

    settings.index = input.index()
    settings.line = @line
    settings.charPos = @charPositionInLine
    settings.dfaState = dfaState
  end


  def addDFAEdge_dfastate_atnconfigset(from, t, q)
    suppressEdge = q.hasSemanticContext
    q.hasSemanticContext = false

    to = addDFAState(q)

    if (suppressEdge)
      return to
    end

    addDFAEdge_dfastate_dfastate(from, t, to)
    return to
  end

  def addDFAEdge_dfastate_dfastate(p, t, q)
    if (t < MIN_DFA_EDGE || t > MAX_DFA_EDGE)
      # Only track edges within the DFA bounds
      return
    end

    if (@debug)
      message = "EDGE " << p.to_s << " -> " << q.to_s << " upon " << t
      puts(message)
    end

    if (p.edges == nil)
      #  make room for tokens 1..n and -1 masquerading as index 0
      p.edges = []
    end
    p.edges[t - MIN_DFA_EDGE] = q # connect
  end


  def addDFAState(configs)


    proposed = DFAState.new(configs)
    firstConfigWithRuleStopState = configs.findFirstRuleStopState

    if (firstConfigWithRuleStopState != nil)
      proposed.isAcceptState = true
      proposed.lexerActionExecutor = firstConfigWithRuleStopState.lexerActionExecutor
      proposed.prediction = atn.ruleToTokenType[firstConfigWithRuleStopState.state.ruleIndex]
    end

    dfa = @decisionToDFA[@mode]

    existing = dfa.states[proposed]
    if (existing != nil)
      return existing
    end

    newState = proposed

    newState.stateNumber = dfa.states.size()
    configs.readonly = true
    newState.configs = configs
    dfa.states[newState] = newState
    return newState
  end


  def getDFA (mode)
    return @decisionToDFA[mode]
  end


  def getText(input)
# index is first lookahead char, don' t include.
    return input.getText(Interval.of(startIndex, input.index() - 1))
  end

  def getLine()
    @line
  end

  def setLine(line)
    @line = line
  end

  def getCharPositionInLine()
    return @charPositionInLine
  end

  def setCharPositionInLine(charPositionInLine)
    @charPositionInLine = charPositionInLine
  end

  def consume(input)
    curChar = input.LA(1)
    if (curChar == '\n')
      @line += 1
      @charPositionInLine = 0
    else
      @charPositionInLine += 1
    end
    input.consume()
  end


  def getTokenName(t)
    if (t == -1)
      return "EOF"
    end
    #if ( atn.g!=nil ) return atn.g.getTokenDisplayName(t)
    return "'" + t.to_s + "'"
  end
end
