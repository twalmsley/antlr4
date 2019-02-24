require '../antlr4/PredictionContext'
require '../antlr4/SemanticContext'
require '../antlr4/Array2DHashSet'

class ATNConfigSet

  attr_accessor :hasSemanticContext
  attr_accessor :readonly
  attr_accessor :configs

  def initialize
    @hasSemanticContext = false
    @readonly = false
    @configLookup = ConfigHashSet.new
    @configs = []
    @dipsIntoOuterContext = false
  end

  def add(config, mergeCache = nil)
    if (@readonly)
      raise IllegalStateException, "This set is readonly"
    end

    if (config.semanticContext != SemanticContext::NONE)
      @hasSemanticContext = true
    end

    if (config.getOuterContextDepth() > 0)

      @dipsIntoOuterContext = true
    end

    if @configLookup.contains config
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

    existing.context = merged
    return true
  end

  def findFirstRuleStopState
    result = nil
    iter = @configLookup.iterator
    while(iter.hasNext)
      x = iter.next
      if (x.state.is_a? RuleStopState)
        result = x
        break
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

  class AbstractConfigHashSet < Array2DHashSet
    def initialize(comparator)
      super(comparator, 16, 16)
    end
  end

  class ConfigHashSet < AbstractConfigHashSet
    def initialize()
      super(ConfigEqualityComparator.instance)
    end
  end

  class ConfigEqualityComparator
    include Singleton

    def hashCode(o)
      hashCode = 7
      hashCode = 31 * hashCode + o.state.stateNumber
      hashCode = 31 * hashCode + o.alt
      hashCode = 31 * hashCode + o.semanticContext.hash()
      return hashCode
    end

    def equals(a, b)
      if (a == b)
        return true
      end
      if (a == nil || b == nil)
        return false
      end

      return a.state.stateNumber == b.state.stateNumber && a.alt == b.alt && a.semanticContext.equals(b.semanticContext)
    end
  end

end
