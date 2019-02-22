require '../../antlr4/runtime/Ruby/antlr4/PredictionContext'
require '../../antlr4/runtime/Ruby/antlr4/SemanticContext'
require 'set'

class ATNConfigSet

  attr_accessor :hasSemanticContext
  attr_accessor :readonly

  def initialize
    @hasSemanticContext = false
    @readonly = false
    @configLookup = Set.new
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

    if @configLookup.include? config
      @cachedHashCode = -1
      @configs.add(config)
      return true
    else
      @configLookup.add(config)
      existing = config
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

  def each
    @configLookup.each
  end

  def empty?
    @configLookup.empty?
  end
end
