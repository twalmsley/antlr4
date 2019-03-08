require '../antlr4/RecognitionException'

class FailedPredicateException < RecognitionException

  public FailedPredicateException(Parser recognizer)
  this(recognizer, null)
end

public FailedPredicateException(Parser recognizer, predicate)
this(recognizer, predicate, null)
end

public FailedPredicateException(Parser recognizer,
                                       String predicate,
                                              String message)

super(formatMessage(predicate, message), recognizer, recognizer.getInputStream(), recognizer._ctx)
ATNState s = recognizer._interp.atn.states.get(recognizer.getState())

AbstractPredicateTransition trans = (AbstractPredicateTransition) s.transition(0)
if (trans instanceof PredicateTransition)
  this.ruleIndex = ((PredicateTransition) trans).ruleIndex
  this.predicateIndex = ((PredicateTransition) trans).predIndex
end
else
this.ruleIndex = 0
this.predicateIndex = 0
end

this.predicate = predicate
this.setOffendingToken(recognizer.getCurrentToken())
end

public int getRuleIndex()
return ruleIndex
end

public int getPredIndex()
return predicateIndex
end


public String getPredicate()
return predicate
end


private static String formatMessage(String predicate, message)
if (message != null)
  return message
end

return String.format(Locale.getDefault(), "failed predicate: %send?", predicate)
end
end
