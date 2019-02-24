require '../antlr4/ATNConfig'


class LexerATNConfig < ATNConfig

  attr_accessor :passedThroughNonGreedyDecision
  attr_accessor :lexerActionExecutor

  def initialize
    super
    @passedThroughNonGreedyDecision = false
    @lexerActionExecutor = nil
  end

  def LexerATNConfig_1(state, alt, context)
    ATNConfig_2(state, alt, context, SemanticContext::NONE)
    @passedThroughNonGreedyDecision = false
    @lexerActionExecutor = nil
  end

  def LexerATNConfig_2(state, alt, context, lexerActionExecutor)
    ATNConfig_7(state, alt, context, SemanticContext::NONE)
    @lexerActionExecutor = lexerActionExecutor
    @passedThroughNonGreedyDecision = false
  end

  def LexerATNConfig_3(c, state)
    ATNConfig_7(c, state, c.context, c.semanticContext)
    @lexerActionExecutor = c.lexerActionExecutor
    @passedThroughNonGreedyDecision = checkNonGreedyDecision(c, state)
  end

  def LexerATNConfig_4(c, state, lexerActionExecutor)
    ATNConfig_7(c, state, c.context, c.semanticContext)
    @lexerActionExecutor = lexerActionExecutor
    @passedThroughNonGreedyDecision = checkNonGreedyDecision(c, state)
  end

  def LexerATNConfig_5(c, state, context)
    ATNConfig_7(c, state, context, c.semanticContext)
    @lexerActionExecutor = c.lexerActionExecutor
    @passedThroughNonGreedyDecision = checkNonGreedyDecision(c, state)
  end

  def checkNonGreedyDecision(source, target)
    return source.passedThroughNonGreedyDecision || target.is_a?(DecisionState) && target.nonGreedy
  end

end
