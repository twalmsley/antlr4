require '../antlr4/PredictionContext'
require '../antlr4/SemanticContext'
require '../antlr4/Array2DHashSet'

class ATNConfigSet

  attr_accessor :hasSemanticContext
  attr_accessor :readonly
  attr_accessor :configs
  attr_accessor :uniqueAlt
  attr_accessor :dipsIntoOuterContext
  attr_accessor :fullCtx
  attr_accessor :conflictingAlts

  def initialize(fullCtx = true)
    @fullCtx = fullCtx
    @hasSemanticContext = false
    @readonly = false
    @configLookup = ConfigHashSet.new
    @configs = []
    @dipsIntoOuterContext = false
    @uniqueAlt = ATN::INVALID_ALT_NUMBER
  end

  def getAlts()
    alts = BitSet.new()
    @configs.each do |config|
      alts.set(config.alt)
    end
    return alts
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

    existing = @configLookup.getOrAdd config
    if existing == config
      @cachedHashCode = -1
      @configs << config
      return true
    end

    rootIsWildcard = !@fullCtx

    merged = PredictionContextUtils.merge(existing.context, config.context, rootIsWildcard, mergeCache)

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
    while (iter.hasNext)
      x = iter.next
      if (x.state.is_a? RuleStopState)
        result = x
        break
      end
    end
    return result
  end

  def empty?
    @configLookup.isEmpty
  end

  def to_s()
    buf = ""
    buf << '<'
    @configs.each do |c|
      buf << c.to_s << ' '
    end
    buf << '>'

    if (@hasSemanticContext)
      buf << ",hasSemanticContext=" << @hasSemanticContext.to_s
    end
    if (@uniqueAlt != ATN::INVALID_ALT_NUMBER)
      buf << ",uniqueAlt=" << @uniqueAlt
    end
    if (@conflictingAlts != nil)
      buf << ",conflictingAlts=" << @conflictingAlts.to_s
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

  def optimizeConfigs(interpreter)
    if (@readonly)
      raise IllegalStateException, "This set is readonly"
    end
    if (@configLookup.isEmpty)
      return
    end

    @configs.each do |config|
      config.context = interpreter.getCachedContext(config.context);
    end
  end

  class ConfigEqualityComparator
    include Singleton

    def hash(o)
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

  def size
    @configs.length
  end
end
