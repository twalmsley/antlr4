require '../antlr4/Integer'
require '../antlr4/RuleContext'
require '../antlr4/ArrayPredictionContext'

class PredictionContextUtils

  INITIAL_HASH = 1
  EMPTY_RETURN_STATE = Integer::MAX

  def self.fromRuleContext(atn, outerContext)
    if (outerContext == nil)
      outerContext = ParserRuleContext::EMPTY
    end

    # if we are in RuleContext of start rule, s, then PredictionContext
    # is EMPTY. Nobody called us. (if we are empty, return empty)
    if (outerContext.parent == nil || outerContext == ParserRuleContext::EMPTY)
      return EmptyPredictionContext::EMPTY
    end

    # If we have a parent, convert it to a PredictionContext graph
    parent = PredictionContextUtils.fromRuleContext(atn, outerContext.parent)

    state = atn.states[outerContext.invokingState]
    transition = state.transition(0)
    return SingletonPredictionContext.new(parent, transition.followState.stateNumber)
  end

  def self.merge(a, b, rootIsWildcard, mergeCache)

# share same graph if both same
    if (a == b || a.equals(b))
      return a
    end

    if (a.class.name == "SingletonPredictionContext" && b.class.name == "SingletonPredictionContext")
      return mergeSingletons(a, b, rootIsWildcard, mergeCache)
    end

    # At least one of a or b is array
    # If one is $ and rootIsWildcard, return $ as * wildcard
    if (rootIsWildcard)
      if (a.is_a? EmptyPredictionContext)
        return a
      end
      if (b.is_a? EmptyPredictionContext)
        return b
      end
    end

    # convert singleton so both are arrays to normalize
    if (a.is_a? SingletonPredictionContext)
      a = ArrayPredictionContext.new(a)
    end
    if (b.is_a? SingletonPredictionContext)
      b = ArrayPredictionContext.new(b)
    end
    return mergeArrays(a, b, rootIsWildcard, mergeCache)
  end


  def self.mergeSingletons(a, b, rootIsWildcard, mergeCache)

    if (mergeCache != nil)
      previous = mergeCache.get2(a, b)
      if (previous != nil)
        return previous
      end
      previous = mergeCache.get2(b, a)
      if (previous != nil)
        return previous
      end
    end

    rootMerge = mergeRoot(a, b, rootIsWildcard)
    if (rootMerge != nil)
      if (mergeCache != nil)
        mergeCache.put(a, b, rootMerge)
      end
      return rootMerge
    end

    if (a.returnState == b.returnState) # a == b
      parent = merge(a.parent, b.parent, rootIsWildcard, mergeCache)
      # if parent is same as existing a or b parent or reduced to a parent, return it
      if (parent == a.parent)
        return a # ax + bx = ax, if a=b
      end
      if (parent == b.parent)
        return b # ax + bx = bx, if a=b
      end
      # else: ax + ay = a'[x,y]
      # merge parents x and y, giving array node with x,y then remainders
      # of those graphs.  dup a, a' points at merged array
      # new joined parent so create new singleton pointing to it, a'
      a_ = SingletonPredictionContext.new(parent, a.returnState)
      if (mergeCache != nil)
        mergeCache.put(a, b, a_)
      end
      return a_
    else # a != b payloads differ
      # see if we can collapse parents due to $+x parents if local ctx
      singleParent = nil
      if (a == b || (a.parent != nil && a.parent.equals(b.parent))) # ax + bx = [a,b]x
        singleParent = a.parent
      end
      if (singleParent != nil) # parents are same
        # sort payloads and use same parent
        payloads = [a.returnState, b.returnState]
        if (a.returnState > b.returnState)
          payloads[0] = b.returnState
          payloads[1] = a.returnState
        end
        parents = [singleParent, singleParent]
        a_ = ArrayPredictionContext.new(parents, payloads)
        if (mergeCache != nil)
          mergeCache.put(a, b, a_)
        end
        return a_
      end
      # parents differ and can't merge them. Just pack together
      # into array can't merge.
      # ax + by = [ax,by]
      payloads = [a.returnState, b.returnState]
      parents = [a.parent, b.parent]
      if (a.returnState > b.returnState) # sort by payload
        payloads[0] = b.returnState
        payloads[1] = a.returnState
        parents = [b.parent, a.parent]
      end
      a_ = ArrayPredictionContext.new(parents, payloads)
      if (mergeCache != nil)
        mergeCache.put(a, b, a_)
      end
      return a_
    end
  end


  def self.mergeRoot(a, b, rootIsWildcard)

    if (rootIsWildcard)
      if (a.returnState == EMPTY_RETURN_STATE)
        return EmptyPredictionContext::EMPTY # * + b = *
      end
      if (b.returnState == EMPTY_RETURN_STATE)
        return EmptyPredictionContext::EMPTY # a + * = *
      end
    else
      if (a.returnState == EMPTY_RETURN_STATE && b.returnState == EMPTY_RETURN_STATE)
        return EmptyPredictionContext::EMPTY # $ + $ = $
      end
      if (a.returnState == EMPTY_RETURN_STATE) # $ + x = [x,$]
        payloads = [b.returnState, EMPTY_RETURN_STATE]
        parents = [b.parent, nil]
        joined = ArrayPredictionContext.new(parents, payloads)
        return joined
      end
      if (b.returnState == EMPTY_RETURN_STATE) # x + $ = [x,$] ($ is always last if present)
        payloads = [a.returnState, EMPTY_RETURN_STATE]
        parents = [a.parent, nil]
        joined = ArrayPredictionContext.new(parents, payloads)
        return joined
      end
    end
    return nil
  end


  def self.mergeArrays(a, b, rootIsWildcard, mergeCache)
    if (mergeCache != nil)
      previous = mergeCache.get2(a, b)
      if (previous != nil)
        return previous
      end
      previous = mergeCache.get2(b, a)
      if (previous != nil)
        return previous
      end
    end

    # merge sorted payloads a + b => M
    i = 0 # walks a
    j = 0 # walks b
    k = 0 # walks target M array

    mergedReturnStates = []
    mergedParents = []
    # walk and merge to yield mergedParents, mergedReturnStates
    while (i < a.returnStates.length && j < b.returnStates.length)
      a_parent = a.parents[i]
      b_parent = b.parents[j]
      if (a.returnStates[i] == b.returnStates[j])
        # same payload (stack tops are equal), must yield merged singleton
        payload = a.returnStates[i]
        # $+$ = $
        both = payload == EMPTY_RETURN_STATE &&
            a_parent == nil && b_parent == nil
        ax_ax = (a_parent != nil && b_parent != nil) &&
            a_parent.equals(b_parent) # ax+ax -> ax
        if (both || ax_ax)
          mergedParents[k] = a_parent # choose left
          mergedReturnStates[k] = payload
        else # ax+ay -> a'[x,y]
          mergedParent =
              merge(a_parent, b_parent, rootIsWildcard, mergeCache)
          mergedParents[k] = mergedParent
          mergedReturnStates[k] = payload
        end
        i += 1 # hop over left one as usual
        j += 1 # but also skip one in right side since we merge
      elsif (a.returnStates[i] < b.returnStates[j]) # copy a[i] to M
        mergedParents[k] = a_parent
        mergedReturnStates[k] = a.returnStates[i]
        i += 1
      else # b > a, copy b[j] to M
        mergedParents[k] = b_parent
        mergedReturnStates[k] = b.returnStates[j]
        j += 1
      end

      k += 1
    end

    # copy over any payloads remaining in either array
    if (i < a.returnStates.length)
      p = i
      while p < a.returnStates.length
        mergedParents[k] = a.parents[p]
        mergedReturnStates[k] = a.returnStates[p]
        k += 1
        p += 1
      end
    else
      p = j
      while p < b.returnStates.length
        mergedParents[k] = b.parents[p]
        mergedReturnStates[k] = b.returnStates[p]
        k += 1
        p += 1
      end
    end

    # trim merged if we combined a few that had same stack tops
    if (k < mergedParents.length) # write index < last position trim
      if (k == 1) # for just one merged element, return singleton top
        a_ = SingletonPredictionContext.create(mergedParents[0],
                                               mergedReturnStates[0])
        if (mergeCache != nil)
          mergeCache.put(a, b, a_)
        end
        return a_
      end
    end

    m = ArrayPredictionContext.new(mergedParents, mergedReturnStates)

    # if we created same array as a or b, return that instead
    # TODO: track whether this is possible above during merge sort for speed
    if (m.equals(a))
      if (mergeCache != nil)
        mergeCache.put(a, b, a)
      end
      return a
    end
    if (m.equals(b))
      if (mergeCache != nil)
        mergeCache.put(a, b, b)
      end
      return b
    end

    combineCommonParents(mergedParents)

    if (mergeCache != nil)
      mergeCache.put(a, b, m)
    end
    return m
  end


  def self.combineCommonParents(parents)
    uniqueParents = Hash.new

    p = 0
    while p < parents.length
      parent = parents[p]
      if (!uniqueParents.has_key?(parent)) # don't replace
        uniqueParents[parent] = parent
      end
      p += 1
    end

    p = 0
    while p < parents.length
      parents[p] = uniqueParents[parents[p]]
      p += 1
    end
  end

  def self.toDOTString(context)
    if (context == nil)
      return ""
    end
    buf = ""
    buf << "digraph G \n"
    buf << "rankdir=LR\n"

    nodes = getAllContextNodes(context)
    nodes.sort {|a, b| a.id - b.id}

    nodes.each do |current|
      if (current.is_a? SingletonPredictionContext)
        s = current.id.to_s
        buf << "  s" << s
        returnState = current.getReturnState(0).to_s
        if (current.is_a? EmptyPredictionContext)
          returnState = "$"
        end
        buf << " [label=\"" << returnState << "\"]\n"
        next
      end
      arr = current
      buf << "  s" << arr.id
      buf << " [shape=box, label=\""
      buf << "["
      first = true
      arr.returnStates.each do |inv|
        if (!first)
          buf << ", "
        end
        if (inv == EMPTY_RETURN_STATE)
          buf << "$"
        else
          buf << inv
        end
        first = false
      end
      buf << "]"
      buf << "\"]\n"
    end

    nodes.each do |current|
      if (current == EMPTY)
        next
      end
      i = 0
      while i < current.size
        if (current.getParent(i) == nil)
          i += 1
          next
        end
        String s = String.valueOf(current.id)
        buf << "  s" << s
        buf << "->"
        buf << "s"
        buf << current.getParent(i).id
        if (current.size() > 1)
          buf << " [label=\"parent[" + i + "]\"]\n"
        else
          buf << "\n"
        end
        i += 1
      end
    end

    buf << "end\n"
    return buf
  end

  def self.getCachedContext(context, contextCache, visited)

    if (context.isEmpty())
      return context
    end

    existing = visited[context]
    if (existing != nil)
      return existing
    end

    existing = contextCache.get(context)
    if (existing != nil)
      visited[context] = existing
      return existing
    end

    changed = false
    parents = []
    i = 0
    while i < parents.length
      parent = getCachedContext(context.getParent(i), contextCache, visited)
      if (changed || parent != context.getParent(i))
        if (!changed)
          parents = []
          j = 0
          while j < context.size()
            parents[j] = context.getParent(j)
            j += 1
          end
          changed = true
        end
        parents[i] = parent
      end
      i += 1
    end

    if (!changed)
      contextCache.add(context)
      visited[context] = context
      return context
    end

    updated = nil
    if (parents.length == 0)
      updated = EMPTY
    elsif (parents.length == 1)
      updated = SingletonPredictionContext.create(parents[0], context.getReturnState(0))
    else
      arrayPredictionContext = context
      updated = ArrayPredictionContext.new(parents, arrayPredictionContext.returnStates)
    end

    contextCache.add(updated)
    visited[updated] = updated
    visited[context] = updated

    return updated
  end

  def self.getAllContextNodes(context)
    nodes = []
    visited = Hash.new
    getAllContextNodes_(context, nodes, visited)
    return nodes
  end

  def self.getAllContextNodes_(context, nodes, visited)

    if (context == nil || visited.has_key?(context))
      return
    end
    visited[context] = context
    nodes.add(context)
    i = 0
    while i < context.size()
      getAllContextNodes_(context.getParent(i), nodes, visited)
      i += 1
    end
  end

  def self.calculateEmptyHashCode()
    hash = INITIAL_HASH
    hash = MurmurHash.finish(hash, 0)
    return hash
  end

  def self.calculateHashCode_1(parent, returnState)
    hash = INITIAL_HASH
    hash = MurmurHash.update_obj(hash, parent)
    hash = MurmurHash.update_int(hash, returnState)
    hash = MurmurHash.finish(hash, 2)
    return hash
  end

  def self.calculateHashCode_2(parents, returnStates)
    hash = INITIAL_HASH

    parents.each do |parent|
      hash = MurmurHash.update_obj(hash, parent)
    end

    returnStates.each do |returnState|
      hash = MurmurHash.update_int(hash, returnState)
    end

    hash = MurmurHash.finish(hash, 2 * parents.length)
    return hash
  end


end

