require '../antlr4/Token'

class LL1Analyzer
  @@HIT_PRED = Token::INVALID_TYPE

  def initialize(atn)
    @atn = atn
  end

  def getDecisionLookahead(s)

    if (s == nil)
      return nil
    end

    look = []
    alt = 0
    while alt < s.getNumberOfTransitions()
      look[alt] = new IntervalSet()
      lookBusy = Set.new
      seeThruPreds = false # fail to get lookahead upon pred
      _LOOK(s.transition(alt).target, nil, PredictionContext.EMPTY,
            look[alt], lookBusy, BitSet.new, seeThruPreds, false)
      # Wipe out lookahead for this alternative if we found nothing
      # or we had a predicate when we !seeThruPreds
      if (look[alt].size() == 0 || look[alt].include?(HIT_PRED))
        look[alt] = nil
      end
      alt += 1
    end
    return look
  end

  def LOOK(s, stopState, ctx)
    r = IntervalSet.new()
    seeThruPreds = true # ignore preds get all lookahead
    lookContext = ctx != nil ? PredictionContext.fromRuleContext(s.atn, ctx) : nil
    _LOOK(s, stopState, lookContext,
          r, Set.new, BitSet.new, seeThruPreds, true)
    return r
  end

  def _LOOK(s,
            stopState,
            ctx,
            look,
            lookBusy,
            calledRuleStack,
            seeThruPreds, addEOF)

#		System.out.println("_LOOK("+s.stateNumber+", ctx="+ctx)
    c = ATNConfig.new(s, 0, ctx)
    if (!lookBusy.add(c))
      return
    end

    if (s == stopState)
      if (ctx == nil)
        look.add(Token::EPSILON)
        return
      elsif (ctx.isEmpty() && addEOF)
        look.add(Token::EOF)
        return
      end
    end

    if (s.is_a? RuleStopState)
      if (ctx == nil)
        look.add(Token::EPSILON)
        return
      elsif (ctx.isEmpty() && addEOF)
        look.add(Token::EOF)
        return
      end

      if (ctx != PredictionContext.EMPTY)
        # run thru all possible stack tops in ctx
        removed = calledRuleStack.get(s.ruleIndex)
        begin
          calledRuleStack.clear(s.ruleIndex)
          i = 0
          while i < ctx.size()
            returnState = atn.states.get(ctx.getReturnState(i))

            _LOOK(returnState, stopState, ctx.getParent(i), look, lookBusy, calledRuleStack, seeThruPreds, addEOF)
            i += 1
          end
        ensure
          if (removed)
            calledRuleStack.set(s.ruleIndex)
          end
        end
        return
      end
    end

    n = s.getNumberOfTransitions()
    i = 0
    while i < n
      t = s.transition(i)
      if (t.instance_of? RuleTransition.class)
        if calledRuleStack.get(t.target.ruleIndex)
          next
        end

        newContext =
            SingletonPredictionContext.create(ctx, t.followState.stateNumber)

        begin
          calledRuleStack.set(t.target.ruleIndex)
          _LOOK(t.target, stopState, newContext, look, lookBusy, calledRuleStack, seeThruPreds, addEOF)
        ensure
          calledRuleStack.clear(t.target.ruleIndex)
        end
      elsif (t.is_a? AbstractPredicateTransition)
        if (seeThruPreds)
          _LOOK(t.target, stopState, ctx, look, lookBusy, calledRuleStack, seeThruPreds, addEOF)
        else
          look.add(HIT_PRED)
        end
      elsif (t.isEpsilon())
        _LOOK(t.target, stopState, ctx, look, lookBusy, calledRuleStack, seeThruPreds, addEOF)
      elsif (t.getClass() == WildcardTransition.class)
        look.addAll(IntervalSet.of(Token::MIN_USER_TOKEN_TYPE, atn.maxTokenType))
      else
        set = t.label()
        if (set != nil)
          if (t.is_a? NotSetTransition)
            set = set.complement(IntervalSet.of(Token::MIN_USER_TOKEN_TYPE, atn.maxTokenType))
          end
          look.addAll(set)
        end
      end

      i += 1
    end
  end
end
