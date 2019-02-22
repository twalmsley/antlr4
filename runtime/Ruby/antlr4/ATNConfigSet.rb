require '../../antlr4/runtime/Ruby/antlr4/PredictionContext'
require '../../antlr4/runtime/Ruby/antlr4/SemanticContext'
require 'set'

class ATNConfigSet

  attr_accessor :hasSemanticContext
  attr_accessor :readonly
  attr_accessor :configs

  def initialize
    @hasSemanticContext = false
    @readonly = false
    @configLookup = Set.new
    @configs = []
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

  def findFirstRuleStopState
    result = nil
    @configLookup.each do |x|
      if(x.state.is_a? RuleStopState)
        result = x;
      end
    end
    return result
  end

  def empty?
    @configLookup.empty?
  end

  def to_s()
    buf = ""
    buf << @configs.to_s

    if (@hasSemanticContext)
      buf << ",hasSemanticContext=" << @hasSemanticContext
    end
    if (@uniqueAlt != ATN.INVALID_ALT_NUMBER)
      buf << ",uniqueAlt=" << @uniqueAlt
    end
    if (@conflictingAlts != nil)
      buf << ",conflictingAlts=" << @conflictingAlts
    end
    if (@dipsIntoOuterContext)
      buf << ",dipsIntoOuterContext"
    end
    return buf
  end

end
