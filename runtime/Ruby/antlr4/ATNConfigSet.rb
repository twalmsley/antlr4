require '../../antlr4/runtime/Ruby/antlr4/SemanticContext'
require 'set'

class ATNConfigSet < Set

  def initialize
    @hasSemanticContext = false
    @readonly = false
  end

  def add(config, mergeCache = nil)
    if (@readonly)
      raise IllegalStateException, "This set is readonly"
    end

    if (config.semanticContext != SemanticContext.NONE)
      @hasSemanticContext = true
    end
    if (config.getOuterContextDepth() > 0)

      @dipsIntoOuterContext = true
    end
    existing = configLookup.getOrAdd(config)

    if (existing == config)
      @cachedHashCode = -1
      @configs.add(config)
      return true
    end
    rootIsWildcard = !@fullCtx
    merged = PredictionContext.merge(existing.context, config.context, rootIsWildcard, mergeCache)

    existing.reachesIntoOuterContext = [existing.reachesIntoOuterContext, config.reachesIntoOuterContext].max

    if (config.isPrecedenceFilterSuppressed())
      existing.setPrecedenceFilterSuppressed(true)
    end

    existing.context = merged;
    return true;
  end

end
