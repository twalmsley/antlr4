require 'singleton'
require '../antlr4/FlexibleHashMap'
require '../antlr4/BitSet'

class PredictionMode
  SLL = 0
  LL = 1
  LL_EXACT_AMBIG_DETECTION = 2


  class AltAndContextMap < FlexibleHashMap

    def initialize()
      super(AltAndContextConfigEqualityComparator.instance)
    end
  end

  class AltAndContextConfigEqualityComparator
    include Singleton

    def hash(o)
      hashCode = 7
      hashCode = MurmurHash.update_int(hashCode, o.state.stateNumber)
      hashCode = MurmurHash.update_obj(hashCode, o.context)
      hashCode = MurmurHash.finish(hashCode, 2)
      return hashCode
    end


    def equals(a, b)
      if (a == b)
        return true
      end
      if (a == nil || b == nil)
        return false
      end
      return a.state.stateNumber == b.state.stateNumber && a.context.equals(b.context)
    end
  end


  def self.hasSLLConflictTerminatingPrediction(mode, configs)


    if (allConfigsInRuleStopStates(configs))
      return true
    end

# pure SLL mode parsing
    if (mode == PredictionMode::SLL)
      # Don't bother with combining configs from different semantic
      # contexts if we can fail over to full LL costs more time
      # since we'll often fail over anyway.
      if (configs.hasSemanticContext)
        # dup configs, tossing out semantic predicates
        dup = ATNConfigSet.new()
        configs.each do |c|
          c = ATNConfig.new
          c.ATNConfig_5(c, SemanticContext::NONE)
          dup.add(c)
        end
        configs = dup
      end
      # now we have combined contexts for configs with dissimilar preds
    end

# pure SLL or combined SLL+LL mode parsing

    altsets = getConflictingAltSubsets(configs)
    heuristic = hasConflictingAltSet(altsets) && !hasStateAssociatedWithOneAlt(configs)
    return heuristic
  end


  def hasConfigInRuleStopState(configs)
    configs.each do |c|
      if (c.state.is_a? RuleStopState)
        return true
      end
    end

    return false
  end


  def self.allConfigsInRuleStopStates(configs)
    configs.configs.each do |config|
      if (!(config.state.is_a? RuleStopState))
        return false
      end
    end

    return true
  end


  def self.resolvesToJustOneViableAlt(altsets)
    return getSingleViableAlt(altsets)
  end


  def self.allSubsetsConflict(altsets)
    return !hasNonConflictingAltSet(altsets)
  end


  def self.hasNonConflictingAltSet(altsets)
    altsets.each do |alts|
      if (alts.cardinality() == 1)
        return true
      end
    end
    return false
  end


  def self.hasConflictingAltSet(altsets)
    altsets.each do |alts|
      if (alts.cardinality() > 1)
        return true
      end
    end
    return false
  end


  def allSubsetsEqual(altsets)

    first = nil
    altsets.each_index do |alt, i|
      if i == 0
        first = altsets[0]
      else
        if (!alt.equals(first))
          return false
        end
      end

    end
    return true
  end


  def self.getUniqueAlt(altsets)
    all = getAlts(altsets)
    if (all.cardinality() == 1)
      return all.nextSetBit(0)
    end
    return ATN::INVALID_ALT_NUMBER
  end


  def self.getAlts_1(altsets)
    all = BitSet.new()
    altsets.each do |alts|
      all.or(alts)
    end
    return all
  end


  def getAlts_2(configs)
    alts = BitSet.new()
    configs.each do |config|
      alts.set(config.alt)
    end
    return alts
  end


  def self.getConflictingAltSubsets(configs)
    configToAlts = AltAndContextMap.new()
    configs.configs.each do |c|
      alts = configToAlts.get(c)
      if (alts == nil)
        alts = BitSet.new()
        configToAlts.put(c, alts)
      end
      alts.set(c.alt)
    end
    return configToAlts.values()
  end


  def self.getStateToAltMap(configs)
    m = Hash.new
    configs.configs.each do |c|
      alts = m[c.state]
      if (alts == nil)
        alts = BitSet.new()
        m[c.state] = alts
      end
      alts.set(c.alt)
    end
    return m
  end

  def self.hasStateAssociatedWithOneAlt(configs)
    x = getStateToAltMap(configs)
    x.values().each do |alts|
      if (alts.cardinality() == 1)
        return true
      end
    end
    return false
  end

  def self.getSingleViableAlt(altsets)
    viableAlts = BitSet.new()
    altsets.each do |alts|
      minAlt = alts.nextSetBit(0)
      viableAlts.set(minAlt)
      if (viableAlts.cardinality() > 1) # more than 1 viable alt
        return ATN::INVALID_ALT_NUMBER
      end
    end
    return viableAlts.nextSetBit(0)
  end

end
