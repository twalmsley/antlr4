require '../../antlr4/runtime/Ruby/antlr4/ATNConfig'


class LexerATNConfig < ATNConfig

  attr_accessor :passedThroughNonGreedyDecision
  attr_accessor :lexerActionExecutor

  def initialize
    super
    @passedThroughNonGreedyDecision = false
    @lexerActionExecutor = nil
  end

  def self.create_from_target(state, alt, context)
    config = LexerATNConfig.new
    config.alt = alt
    config.state = state
    config.context = context
    return config
  end

  def self.create_from_config(cfg, state)
    config = LexerATNConfig.new
    config.alt = cfg.alt
    config.state = state
    config.reachesIntoOuterContext = cfg.reachesIntoOuterContext
    return config
  end

  def self.create_from_config2(cfg, state, context)
    config = LexerATNConfig.new
    config.alt = cfg.alt
    config.state = state
    config.reachesIntoOuterContext = cfg.reachesIntoOuterContext
    config.context = context
    return config
  end
end
