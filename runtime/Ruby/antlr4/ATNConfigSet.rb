class ATNConfigSet
  implements Set < ATNConfig >


                 public static class ConfigHashSet
                                 extends AbstractConfigHashSet
                                 public ConfigHashSet()
                                 super(ConfigEqualityComparator.INSTANCE)
                               end
end

public static final class ConfigEqualityComparator
                      extends AbstractEqualityComparator < ATNConfig >
                                  public static final ConfigEqualityComparator INSTANCE = new ConfigEqualityComparator()

                      private ConfigEqualityComparator()
                    end


public int hashCode(ATNConfig o)
int hashCode = 7
hashCode = 31 * hashCode + o.state.stateNumber
hashCode = 31 * hashCode + o.alt
hashCode = 31 * hashCode + o.semanticContext.hashCode()
return hashCode
end


public boolean equals(ATNConfig a, ATNConfig b)
if (a == b)
  return true
  if (a == null || b == null)
    return false
    return a.state.stateNumber == b.state.stateNumber
    && a.alt == b.alt
    && a.semanticContext.equals(b.semanticContext)
  end
end


protected boolean readonly = false


public AbstractConfigHashSet configLookup


public final ArrayList < ATNConfig > configs = new ArrayList < ATNConfig > (7)

# TODO: these fields make me pretty uncomfortable but nice to pack up info together, saves recomputation
# TODO: can we track conflicts as they are added to save scanning configs later?
public int uniqueAlt


protected BitSet conflictingAlts

# Used in parser and lexer. In lexer, it indicates we hit a pred
# while computing a closure operation.  Don't make a DFA state from this.
public boolean hasSemanticContext
public boolean dipsIntoOuterContext


public final boolean fullCtx

private int cachedHashCode = -1

public ATNConfigSet(boolean fullCtx)
configLookup = new ConfigHashSet()
this.fullCtx = fullCtx
end
public ATNConfigSet() this(true) end

public ATNConfigSet(ATNConfigSet old)
this(old.fullCtx)
addAll(old)
this.uniqueAlt = old.uniqueAlt
this.conflictingAlts = old.conflictingAlts
this.hasSemanticContext = old.hasSemanticContext
this.dipsIntoOuterContext = old.dipsIntoOuterContext
end


public boolean add(ATNConfig config)
return add(config, null)
end


public boolean add(
                   ATNConfig config,
                             DoubleKeyMap < PredictionContext, PredictionContext, PredictionContext > mergeCache)

if (readonly)
  throw new IllegalStateException("This set is readonly")
  if (config.semanticContext != SemanticContext.NONE)
    hasSemanticContext = true
  end
  if (config.getOuterContextDepth() > 0)
    dipsIntoOuterContext = true
  end
  ATNConfig existing = configLookup.getOrAdd(config)
  if (existing == config) # we added this new one
    cachedHashCode = -1
    configs.add(config) # track order here
    return true
  end
  # a previous (s,i,pi,_), merge with it and save result
  boolean rootIsWildcard = !fullCtx
  PredictionContext merged =
                        PredictionContext.merge(existing.context, config.context, rootIsWildcard, mergeCache)
  # no need to check for existing.context, config.context in cache
  # since only way to create new graphs is "call rule" and here. We
  # cache at both places.
  existing.reachesIntoOuterContext =
      Math.max(existing.reachesIntoOuterContext, config.reachesIntoOuterContext)

  # make sure to preserve the precedence filter suppression during the merge
  if (config.isPrecedenceFilterSuppressed())
    existing.setPrecedenceFilterSuppressed(true)
  end

  existing.context = merged # replace context no need to alt mapping
  return true
end


public List < ATNConfig > elements() return configs end

public Set < ATNState > getStates()
Set < ATNState > states = new HashSet < ATNState > ()
for (ATNConfig c :
  configs)
  states.add(c.state)
end
return states
end


public BitSet getAlts()
BitSet alts = new BitSet()
for (ATNConfig config :
  configs)
  alts.set(config.alt)
end
return alts
end

public List < SemanticContext > getPredicates()
List < SemanticContext > preds = new ArrayList < SemanticContext > ()
for (ATNConfig c :
  configs)
  if (c.semanticContext != SemanticContext.NONE)
    preds.add(c.semanticContext)
  end
end
return preds
end

public ATNConfig get(int i) return configs.get(i) end

public void optimizeConfigs(ATNSimulator interpreter)
if (readonly)
  throw new IllegalStateException("This set is readonly")
  if (configLookup.isEmpty())
    return

    for (ATNConfig config :
      configs)
#			int before = PredictionContext.getAllContextNodes(config.context).size()
      config.context = interpreter.getCachedContext(config.context)
#			int after = PredictionContext.getAllContextNodes(config.context).size()
#			System.out.println("configs "+before+"->"+after)
    end
  end


  public boolean addAll(Collection < ? extends ATNConfig > coll)
  for (ATNConfig c :
    coll) add(c)
    return false
  end


  public boolean equals(Object o)
  if (o == this)
    return true
  end
else
  if (!(o instanceof ATNConfigSet))
    return false
  end

#		System.out.print("equals " + this + ", " + o+" = ")
  ATNConfigSet other = (ATNConfigSet) o
  boolean same = configs != null &&
      configs.equals(other.configs) && # includes stack context
      this.fullCtx == other.fullCtx &&
      this.uniqueAlt == other.uniqueAlt &&
      this.conflictingAlts == other.conflictingAlts &&
      this.hasSemanticContext == other.hasSemanticContext &&
      this.dipsIntoOuterContext == other.dipsIntoOuterContext

#		System.out.println(same)
  return same
end


public int hashCode()
if (isReadonly())
  if (cachedHashCode == -1)
    cachedHashCode = configs.hashCode()
  end

  return cachedHashCode
end

return configs.hashCode()
end


public int size()
return configs.size()
end


public boolean isEmpty()
return configs.isEmpty()
end


public boolean contains(Object o)
if (configLookup == null)
  throw new UnsupportedOperationException("This method is not implemented for readonly sets.")
end

return configLookup.contains(o)
end

public boolean containsFast(ATNConfig obj)
if (configLookup == null)
  throw new UnsupportedOperationException("This method is not implemented for readonly sets.")
end

return configLookup.containsFast(obj)
end


public Iterator < ATNConfig > iterator()
return configs.iterator()
end


public void clear()
if (readonly)
  throw new IllegalStateException("This set is readonly")
  configs.clear()
  cachedHashCode = -1
  configLookup.clear()
end

public boolean isReadonly()
return readonly
end

public void setReadonly(boolean readonly)
this.readonly = readonly
configLookup = null # can't mod, no need for lookup cache
end


public String toString()
StringBuilder buf = StringBuilder.new()
buf.append(elements().to_s())
if (hasSemanticContext)
  buf.append(",hasSemanticContext=").append(hasSemanticContext)
  if (uniqueAlt != ATN.INVALID_ALT_NUMBER)
    buf.append(",uniqueAlt=").append(uniqueAlt)
    if (conflictingAlts != null)
      buf.append(",conflictingAlts=").append(conflictingAlts)
      if (dipsIntoOuterContext)
        buf.append(",dipsIntoOuterContext")
        return buf.to_s()
      end

      # satisfy interface


      public ATNConfig[] toArray()
      return configLookup.toArray()
    end


    public < T > toArray(a)
    return configLookup.toArray(a)
  end


  public boolean remove(Object o)
  throw new UnsupportedOperationException()
end


public boolean containsAll(Collection < ?> c)
throw new UnsupportedOperationException()
end


public boolean retainAll(Collection < ?> c)
throw new UnsupportedOperationException()
end


public boolean removeAll(Collection < ?> c)
throw new UnsupportedOperationException()
end

public static abstract class AbstractConfigHashSet
                         extends Array2DHashSet < ATNConfig >

                                     public AbstractConfigHashSet(AbstractEqualityComparator < ? super ATNConfig > comparator)
                         this(comparator, 16, 2)
                       end

public AbstractConfigHashSet(AbstractEqualityComparator < ? super ATNConfig > comparator, int initialCapacity, int initialBucketCapacity)
super(comparator, initialCapacity, initialBucketCapacity)
end


protected final ATNConfig asElementType(Object o)
if (!(o instanceof ATNConfig))
  return null
end

return (ATNConfig) o
end


protected final ATNConfig[][] createBuckets(int capacity)
return new ATNConfig[capacity][]
end


protected final ATNConfig[] createBucket(int capacity)
return new ATNConfig[capacity]
end

end
end
