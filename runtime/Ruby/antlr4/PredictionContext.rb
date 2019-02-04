





















public abstract class PredictionContext 




	public static final EmptyPredictionContext EMPTY = new EmptyPredictionContext()






	public static final int EMPTY_RETURN_STATE = Integer.MAX_VALUE

	private static final int INITIAL_HASH = 1

	def self.globalNodeCount = 0
	public final int id = globalNodeCount++






















	public final int cachedHashCode

	protected PredictionContext(int cachedHashCode) 
		this.cachedHashCode = cachedHashCode
	end




	public static PredictionContext fromRuleContext(ATN atn, RuleContext outerContext) 
		if ( outerContext==null ) outerContext = RuleContext.EMPTY

		# if we are in RuleContext of start rule, s, then PredictionContext
		# is EMPTY. Nobody called us. (if we are empty, return empty)
		if ( outerContext.parent==null || outerContext==RuleContext.EMPTY ) 
			return PredictionContext.EMPTY
		end

		# If we have a parent, convert it to a PredictionContext graph
		PredictionContext parent = EMPTY
		parent = PredictionContext.fromRuleContext(atn, outerContext.parent)

		ATNState state = atn.states.get(outerContext.invokingState)
		RuleTransition transition = (RuleTransition)state.transition(0)
		return SingletonPredictionContext.create(parent, transition.followState.stateNumber)
	end

	public abstract int size()

	public abstract PredictionContext getParent(int index)

	public abstract int getReturnState(int index)


	public boolean isEmpty() 
		return this == EMPTY
	end

	public boolean hasEmptyPath() 
		# since EMPTY_RETURN_STATE can only appear in the last position, we check last one
		return getReturnState(size() - 1) == EMPTY_RETURN_STATE
	end

	
	public final int hashCode() 
		return cachedHashCode
	end

	
	public abstract boolean equals(Object obj)

	protected static int calculateEmptyHashCode() 
		int hash = MurmurHash.initialize(INITIAL_HASH)
		hash = MurmurHash.finish(hash, 0)
		return hash
	end

	protected static int calculateHashCode(PredictionContext parent, int returnState) 
		int hash = MurmurHash.initialize(INITIAL_HASH)
		hash = MurmurHash.update(hash, parent)
		hash = MurmurHash.update(hash, returnState)
		hash = MurmurHash.finish(hash, 2)
		return hash
	end

	protected static int calculateHashCode(PredictionContext[] parents, int[] returnStates) 
		int hash = MurmurHash.initialize(INITIAL_HASH)

		for (PredictionContext parent : parents) 
			hash = MurmurHash.update(hash, parent)
		end

		for (int returnState : returnStates) 
			hash = MurmurHash.update(hash, returnState)
		end

		hash = MurmurHash.finish(hash, 2 * parents.length)
		return hash
	end

	# dispatch
	public static PredictionContext merge(
		PredictionContext a, PredictionContext b,
		boolean rootIsWildcard,
		DoubleKeyMap<PredictionContext,PredictionContext,PredictionContext> mergeCache)
	
		assert a!=null && b!=null # must be empty context, never null

		# share same graph if both same
		if ( a==b || a.equals(b) ) return a

		if ( a instanceof SingletonPredictionContext && b instanceof SingletonPredictionContext) 
			return mergeSingletons((SingletonPredictionContext)a,
								   (SingletonPredictionContext)b,
								   rootIsWildcard, mergeCache)
		end

		# At least one of a or b is array
		# If one is $ and rootIsWildcard, return $ as * wildcard
		if ( rootIsWildcard ) 
			if ( a instanceof EmptyPredictionContext ) return a
			if ( b instanceof EmptyPredictionContext ) return b
		end

		# convert singleton so both are arrays to normalize
		if ( a instanceof SingletonPredictionContext ) 
			a = new ArrayPredictionContext((SingletonPredictionContext)a)
		end
		if ( b instanceof SingletonPredictionContext) 
			b = new ArrayPredictionContext((SingletonPredictionContext)b)
		end
		return mergeArrays((ArrayPredictionContext) a, (ArrayPredictionContext) b,
						   rootIsWildcard, mergeCache)
	end




























	public static PredictionContext mergeSingletons(
		SingletonPredictionContext a,
		SingletonPredictionContext b,
		boolean rootIsWildcard,
		DoubleKeyMap<PredictionContext,PredictionContext,PredictionContext> mergeCache)
	
		if ( mergeCache!=null ) 
			PredictionContext previous = mergeCache.get(a,b)
			if ( previous!=null ) return previous
			previous = mergeCache.get(b,a)
			if ( previous!=null ) return previous
		end

		PredictionContext rootMerge = mergeRoot(a, b, rootIsWildcard)
		if ( rootMerge!=null ) 
			if ( mergeCache!=null ) mergeCache.put(a, b, rootMerge)
			return rootMerge
		end

		if ( a.returnState==b.returnState )  # a == b
			PredictionContext parent = merge(a.parent, b.parent, rootIsWildcard, mergeCache)
			# if parent is same as existing a or b parent or reduced to a parent, return it
			if ( parent == a.parent ) return a # ax + bx = ax, if a=b
			if ( parent == b.parent ) return b # ax + bx = bx, if a=b
			# else: ax + ay = a'[x,y]
			# merge parents x and y, giving array node with x,y then remainders
			# of those graphs.  dup a, a' points at merged array
			# new joined parent so create new singleton pointing to it, a'
			PredictionContext a_ = SingletonPredictionContext.create(parent, a.returnState)
			if ( mergeCache!=null ) mergeCache.put(a, b, a_)
			return a_
		end
		else  # a != b payloads differ
			# see if we can collapse parents due to $+x parents if local ctx
			PredictionContext singleParent = null
			if ( a==b || (a.parent!=null && a.parent.equals(b.parent)) )  # ax + bx = [a,b]x
				singleParent = a.parent
			end
			if ( singleParent!=null ) 	# parents are same
				# sort payloads and use same parent
				int[] payloads = a.returnState, b.returnStateend
				if ( a.returnState > b.returnState ) 
					payloads[0] = b.returnState
					payloads[1] = a.returnState
				end
				PredictionContext[] parents = singleParent, singleParentend
				PredictionContext a_ = new ArrayPredictionContext(parents, payloads)
				if ( mergeCache!=null ) mergeCache.put(a, b, a_)
				return a_
			end
			# parents differ and can't merge them. Just pack together
			# into array can't merge.
			# ax + by = [ax,by]
			int[] payloads = a.returnState, b.returnStateend
			PredictionContext[] parents = a.parent, b.parentend
			if ( a.returnState > b.returnState )  # sort by payload
				payloads[0] = b.returnState
				payloads[1] = a.returnState
				parents = new PredictionContext[] b.parent, a.parentend
			end
			PredictionContext a_ = new ArrayPredictionContext(parents, payloads)
			if ( mergeCache!=null ) mergeCache.put(a, b, a_)
			return a_
		end
	end







































	public static PredictionContext mergeRoot(SingletonPredictionContext a,
											  SingletonPredictionContext b,
											  boolean rootIsWildcard)
	
		if ( rootIsWildcard ) 
			if ( a == EMPTY ) return EMPTY  # * + b = *
			if ( b == EMPTY ) return EMPTY  # a + * = *
		end
		else 
			if ( a == EMPTY && b == EMPTY ) return EMPTY # $ + $ = $
			if ( a == EMPTY )  # $ + x = [x,$]
				int[] payloads = b.returnState, EMPTY_RETURN_STATEend
				PredictionContext[] parents = b.parent, nullend
				PredictionContext joined =
					new ArrayPredictionContext(parents, payloads)
				return joined
			end
			if ( b == EMPTY )  # x + $ = [x,$] ($ is always last if present)
				int[] payloads = a.returnState, EMPTY_RETURN_STATEend
				PredictionContext[] parents = a.parent, nullend
				PredictionContext joined =
					new ArrayPredictionContext(parents, payloads)
				return joined
			end
		end
		return null
	end




















	public static PredictionContext mergeArrays(
		ArrayPredictionContext a,
		ArrayPredictionContext b,
		boolean rootIsWildcard,
		DoubleKeyMap<PredictionContext,PredictionContext,PredictionContext> mergeCache)
	
		if ( mergeCache!=null ) 
			PredictionContext previous = mergeCache.get(a,b)
			if ( previous!=null ) return previous
			previous = mergeCache.get(b,a)
			if ( previous!=null ) return previous
		end

		# merge sorted payloads a + b => M
		int i = 0 # walks a
		int j = 0 # walks b
		int k = 0 # walks target M array

		int[] mergedReturnStates =
			new int[a.returnStates.length + b.returnStates.length]
		PredictionContext[] mergedParents =
			new PredictionContext[a.returnStates.length + b.returnStates.length]
		# walk and merge to yield mergedParents, mergedReturnStates
		while ( i<a.returnStates.length && j<b.returnStates.length ) 
			PredictionContext a_parent = a.parents[i]
			PredictionContext b_parent = b.parents[j]
			if ( a.returnStates[i]==b.returnStates[j] ) 
				# same payload (stack tops are equal), must yield merged singleton
				int payload = a.returnStates[i]
				# $+$ = $
				boolean both$ = payload == EMPTY_RETURN_STATE &&
								a_parent == null && b_parent == null
				boolean ax_ax = (a_parent!=null && b_parent!=null) &&
								a_parent.equals(b_parent) # ax+ax -> ax
				if ( both$ || ax_ax ) 
					mergedParents[k] = a_parent # choose left
					mergedReturnStates[k] = payload
				end
				else  # ax+ay -> a'[x,y]
					PredictionContext mergedParent =
						merge(a_parent, b_parent, rootIsWildcard, mergeCache)
					mergedParents[k] = mergedParent
					mergedReturnStates[k] = payload
				end
				i++ # hop over left one as usual
				j++ # but also skip one in right side since we merge
			end
			else if ( a.returnStates[i]<b.returnStates[j] )  # copy a[i] to M
				mergedParents[k] = a_parent
				mergedReturnStates[k] = a.returnStates[i]
				i++
			end
			else  # b > a, copy b[j] to M
				mergedParents[k] = b_parent
				mergedReturnStates[k] = b.returnStates[j]
				j++
			end
			k++
		end

		# copy over any payloads remaining in either array
		if (i < a.returnStates.length) 
			for (int p = i p < a.returnStates.length p++) 
				mergedParents[k] = a.parents[p]
				mergedReturnStates[k] = a.returnStates[p]
				k++
			end
		end
		else 
			for (int p = j p < b.returnStates.length p++) 
				mergedParents[k] = b.parents[p]
				mergedReturnStates[k] = b.returnStates[p]
				k++
			end
		end

		# trim merged if we combined a few that had same stack tops
		if ( k < mergedParents.length )  # write index < last position trim
			if ( k == 1 )  # for just one merged element, return singleton top
				PredictionContext a_ =
					SingletonPredictionContext.create(mergedParents[0],
													  mergedReturnStates[0])
				if ( mergeCache!=null ) mergeCache.put(a,b,a_)
				return a_
			end
			mergedParents = Arrays.copyOf(mergedParents, k)
			mergedReturnStates = Arrays.copyOf(mergedReturnStates, k)
		end

		PredictionContext M =
			new ArrayPredictionContext(mergedParents, mergedReturnStates)

		# if we created same array as a or b, return that instead
		# TODO: track whether this is possible above during merge sort for speed
		if ( M.equals(a) ) 
			if ( mergeCache!=null ) mergeCache.put(a,b,a)
			return a
		end
		if ( M.equals(b) ) 
			if ( mergeCache!=null ) mergeCache.put(a,b,b)
			return b
		end

		combineCommonParents(mergedParents)

		if ( mergeCache!=null ) mergeCache.put(a,b,M)
		return M
	end





	protected static void combineCommonParents(PredictionContext[] parents) 
		Map<PredictionContext, PredictionContext> uniqueParents =
			new HashMap<PredictionContext, PredictionContext>()

		for (int p = 0 p < parents.length p++) 
			PredictionContext parent = parents[p]
			if ( !uniqueParents.containsKey(parent) )  # don't replace
				uniqueParents.put(parent, parent)
			end
		end

		for (int p = 0 p < parents.length p++) 
			parents[p] = uniqueParents.get(parents[p])
		end
	end

	def self.toDOTString(PredictionContext context) 
		if ( context==null ) return ""
		StringBuilder buf = StringBuilder.new()
		buf.append("digraph G \n")
		buf.append("rankdir=LR\n")

		List<PredictionContext> nodes = getAllContextNodes(context)
		Collections.sort(nodes, new Comparator<PredictionContext>() 
			
			public int compare(PredictionContext o1, PredictionContext o2) 
				return o1.id - o2.id
			end
		end)

		for (PredictionContext current : nodes) 
			if ( current instanceof SingletonPredictionContext ) 
				String s = String.valueOf(current.id)
				buf.append("  s").append(s)
				String returnState = String.valueOf(current.getReturnState(0))
				if ( current instanceof EmptyPredictionContext ) returnState = "$"
				buf.append(" [label=\"").append(returnState).append("\"]\n")
				continue
			end
			ArrayPredictionContext arr = (ArrayPredictionContext)current
			buf.append("  s").append(arr.id)
			buf.append(" [shape=box, label=\"")
			buf.append("[")
			boolean first = true
			for (int inv : arr.returnStates) 
				if ( !first ) buf.append(", ")
				if ( inv == EMPTY_RETURN_STATE ) buf.append("$")
				else buf.append(inv)
				first = false
			end
			buf.append("]")
			buf.append("\"]\n")
		end

		for (PredictionContext current : nodes) 
			if ( current==EMPTY ) continue
			for (int i = 0 i < current.size() i++) 
				if ( current.getParent(i)==null ) continue
				String s = String.valueOf(current.id)
				buf.append("  s").append(s)
				buf.append("->")
				buf.append("s")
				buf.append(current.getParent(i).id)
				if ( current.size()>1 ) buf.append(" [label=\"parent["+i+"]\"]\n")
				else buf.append("\n")
			end
		end

		buf.append("end\n")
		return buf.to_s()
	end

	# From Sam
	public static PredictionContext getCachedContext(
		PredictionContext context,
		PredictionContextCache contextCache,
		IdentityHashMap<PredictionContext, PredictionContext> visited)
	
		if (context.isEmpty()) 
			return context
		end

		PredictionContext existing = visited.get(context)
		if (existing != null) 
			return existing
		end

		existing = contextCache.get(context)
		if (existing != null) 
			visited.put(context, existing)
			return existing
		end

		boolean changed = false
		PredictionContext[] parents = new PredictionContext[context.size()]
		for (int i = 0 i < parents.length i++) 
			PredictionContext parent = getCachedContext(context.getParent(i), contextCache, visited)
			if (changed || parent != context.getParent(i)) 
				if (!changed) 
					parents = new PredictionContext[context.size()]
					for (int j = 0 j < context.size() j++) 
						parents[j] = context.getParent(j)
					end

					changed = true
				end

				parents[i] = parent
			end
		end

		if (!changed) 
			contextCache.add(context)
			visited.put(context, context)
			return context
		end

		PredictionContext updated
		if (parents.length == 0) 
			updated = EMPTY
		end
		else if (parents.length == 1) 
			updated = SingletonPredictionContext.create(parents[0], context.getReturnState(0))
		end
		else 
			ArrayPredictionContext arrayPredictionContext = (ArrayPredictionContext)context
			updated = new ArrayPredictionContext(parents, arrayPredictionContext.returnStates)
		end

		contextCache.add(updated)
		visited.put(updated, updated)
		visited.put(context, updated)

		return updated
	end

#	# extra structures, but cut/paste/morphed works, so leave it.
#	# seems to do a breadth-first walk
#	public static List<PredictionContext> getAllNodes(PredictionContext context) 
#		Map<PredictionContext, PredictionContext> visited =
#			new IdentityHashMap<PredictionContext, PredictionContext>()
#		Deque<PredictionContext> workList = new ArrayDeque<PredictionContext>()
#		workList.add(context)
#		visited.put(context, context)
#		List<PredictionContext> nodes = new ArrayList<PredictionContext>()
#		while (!workList.isEmpty()) 
#			PredictionContext current = workList.pop()
#			nodes.add(current)
#			for (int i = 0 i < current.size() i++) 
#				PredictionContext parent = current.getParent(i)
#				if ( parent!=null && visited.put(parent, parent) == null) 
#					workList.push(parent)
#				end
#			end
#		end
#		return nodes
#	end

	# ter's recursive version of Sam's getAllNodes()
	public static List<PredictionContext> getAllContextNodes(PredictionContext context) 
		List<PredictionContext> nodes = new ArrayList<PredictionContext>()
		Map<PredictionContext, PredictionContext> visited =
			new IdentityHashMap<PredictionContext, PredictionContext>()
		getAllContextNodes_(context, nodes, visited)
		return nodes
	end

	def self.getAllContextNodes_(PredictionContext context,
										   List<PredictionContext> nodes,
										   Map<PredictionContext, PredictionContext> visited)
	
		if ( context==null || visited.containsKey(context) ) return
		visited.put(context, context)
		nodes.add(context)
		for (int i = 0 i < context.size() i++) 
			getAllContextNodes_(context.getParent(i), nodes, visited)
		end
	end

	public String toString(Recognizer<?,?> recog) 
		return toString()
#		return toString(recog, ParserRuleContext.EMPTY)
	end

	public String[] toStrings(Recognizer<?, ?> recognizer, int currentState) 
		return toStrings(recognizer, EMPTY, currentState)
	end

	# FROM SAM
	public String[] toStrings(Recognizer<?, ?> recognizer, PredictionContext stop, int currentState) 
		List<String> result = new ArrayList<String>()

		outer:
		for (int perm = 0  perm++) 
			int offset = 0
			boolean last = true
			PredictionContext p = this
			int stateNumber = currentState
			StringBuilder localBuffer = StringBuilder.new()
			localBuffer.append("[")
			while ( !p.isEmpty() && p != stop ) 
				int index = 0
				if (p.size() > 0) 
					int bits = 1
					while ((1 << bits) < p.size()) 
						bits++
					end

					int mask = (1 << bits) - 1
					index = (perm >> offset) & mask
					last &= index >= p.size() - 1
					if (index >= p.size()) 
						continue outer
					end
					offset += bits
				end

				if ( recognizer!=null ) 
					if (localBuffer.length() > 1) 
						# first char is '[', if more than that this isn't the first rule
						localBuffer.append(' ')
					end

					ATN atn = recognizer.getATN()
					ATNState s = atn.states.get(stateNumber)
					String ruleName = recognizer.getRuleNames()[s.ruleIndex]
					localBuffer.append(ruleName)
				end
				else if ( p.getReturnState(index)!= EMPTY_RETURN_STATE) 
					if ( !p.isEmpty() ) 
						if (localBuffer.length() > 1) 
							# first char is '[', if more than that this isn't the first rule
							localBuffer.append(' ')
						end

						localBuffer.append(p.getReturnState(index))
					end
				end
				stateNumber = p.getReturnState(index)
				p = p.getParent(index)
			end
			localBuffer.append("]")
			result.add(localBuffer.to_s())

			if (last) 
				break
			end
		end

		return result.toArray(new String[result.size()])
	end
end
