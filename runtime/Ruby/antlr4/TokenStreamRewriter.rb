

























































































class TokenStreamRewriter 
	public static final String DEFAULT_PROGRAM_NAME = "default"
	public static final int PROGRAM_INIT_SIZE = 100
	public static final int MIN_TOKEN_INDEX = 0

	# Define the rewrite operation hierarchy

	class RewriteOperation 

		protected int instructionIndex

		protected int index
		protected Object text

		protected RewriteOperation(int index) 
			this.index = index
		end

		protected RewriteOperation(int index, Object text) 
			this.index = index
			this.text = text
		end



		public int execute(StringBuilder buf) 
			return index
		end

		
		public String toString() 
			String opName = getClass().getName()
			int $index = opName.indexOf('$')
			opName = opName.substring($index+1, opName.length())
			return "<"+opName+"@"+tokens.get(index)+
					":\""+text+"\">"
		end
	end

	class InsertBeforeOp extends RewriteOperation 
		public InsertBeforeOp(int index, Object text) 
			super(index,text)
		end

		
		public int execute(StringBuilder buf) 
			buf.append(text)
			if ( tokens.get(index).getType()!=Token.EOF ) 
				buf.append(tokens.get(index).getText())
			end
			return index+1
		end
	end





    class InsertAfterOp extends InsertBeforeOp 
        public InsertAfterOp(int index, Object text) 
            super(index+1, text) # insert after is insert before index+1
        end
    end




	class ReplaceOp extends RewriteOperation 
		protected int lastIndex
		public ReplaceOp(int from, int to, Object text) 
			super(from,text)
			lastIndex = to
		end
		
		public int execute(StringBuilder buf) 
			if ( text!=null ) 
				buf.append(text)
			end
			return lastIndex+1
		end
		
		public String toString() 
			if ( text==null ) 
				return "<DeleteOp@"+tokens.get(index)+
						".."+tokens.get(lastIndex)+">"
			end
			return "<ReplaceOp@"+tokens.get(index)+
					".."+tokens.get(lastIndex)+":\""+text+"\">"
		end
	end


	protected final TokenStream tokens





	protected final Map<String, List<RewriteOperation>> programs


	protected final Map<String, Integer> lastRewriteTokenIndexes

	public TokenStreamRewriter(TokenStream tokens) 
		this.tokens = tokens
		programs = new HashMap<String, List<RewriteOperation>>()
		programs.put(DEFAULT_PROGRAM_NAME,
					 new ArrayList<RewriteOperation>(PROGRAM_INIT_SIZE))
		lastRewriteTokenIndexes = new HashMap<String, Integer>()
	end

	public final TokenStream getTokenStream() 
		return tokens
	end

	public void rollback(int instructionIndex) 
		rollback(DEFAULT_PROGRAM_NAME, instructionIndex)
	end





	public void rollback(String programName, int instructionIndex) 
		List<RewriteOperation> is = programs.get(programName)
		if ( is!=null ) 
			programs.put(programName, is.subList(MIN_TOKEN_INDEX,instructionIndex))
		end
	end

	public void deleteProgram() 
		deleteProgram(DEFAULT_PROGRAM_NAME)
	end


	public void deleteProgram(String programName) 
		rollback(programName, MIN_TOKEN_INDEX)
	end

	public void insertAfter(Token t, Object text) 
		insertAfter(DEFAULT_PROGRAM_NAME, t, text)
	end

	public void insertAfter(int index, Object text) 
		insertAfter(DEFAULT_PROGRAM_NAME, index, text)
	end

	public void insertAfter(String programName, Token t, Object text) 
		insertAfter(programName,t.getTokenIndex(), text)
	end

	public void insertAfter(String programName, int index, Object text) 
		# to insert after, just insert before next index (even if past end)
        RewriteOperation op = new InsertAfterOp(index, text)
        List<RewriteOperation> rewrites = getProgram(programName)
        op.instructionIndex = rewrites.size()
        rewrites.add(op)
	end

	public void insertBefore(Token t, Object text) 
		insertBefore(DEFAULT_PROGRAM_NAME, t, text)
	end

	public void insertBefore(int index, Object text) 
		insertBefore(DEFAULT_PROGRAM_NAME, index, text)
	end

	public void insertBefore(String programName, Token t, Object text) 
		insertBefore(programName, t.getTokenIndex(), text)
	end

	public void insertBefore(String programName, int index, Object text) 
		RewriteOperation op = new InsertBeforeOp(index,text)
		List<RewriteOperation> rewrites = getProgram(programName)
		op.instructionIndex = rewrites.size()
		rewrites.add(op)
	end

	public void replace(int index, Object text) 
		replace(DEFAULT_PROGRAM_NAME, index, index, text)
	end

	public void replace(int from, int to, Object text) 
		replace(DEFAULT_PROGRAM_NAME, from, to, text)
	end

	public void replace(Token indexT, Object text) 
		replace(DEFAULT_PROGRAM_NAME, indexT, indexT, text)
	end

	public void replace(Token from, Token to, Object text) 
		replace(DEFAULT_PROGRAM_NAME, from, to, text)
	end

	public void replace(String programName, int from, int to, Object text) 
		if ( from > to || from<0 || to<0 || to >= tokens.size() ) 
			throw new IllegalArgumentException("replace: range invalid: "+from+".."+to+"(size="+tokens.size()+")")
		end
		RewriteOperation op = new ReplaceOp(from, to, text)
		List<RewriteOperation> rewrites = getProgram(programName)
		op.instructionIndex = rewrites.size()
		rewrites.add(op)
	end

	public void replace(String programName, Token from, Token to, Object text) 
		replace(programName,
				from.getTokenIndex(),
				to.getTokenIndex(),
				text)
	end

	public void delete(int index) 
		delete(DEFAULT_PROGRAM_NAME, index, index)
	end

	public void delete(int from, int to) 
		delete(DEFAULT_PROGRAM_NAME, from, to)
	end

	public void delete(Token indexT) 
		delete(DEFAULT_PROGRAM_NAME, indexT, indexT)
	end

	public void delete(Token from, Token to) 
		delete(DEFAULT_PROGRAM_NAME, from, to)
	end

	public void delete(String programName, int from, int to) 
		replace(programName,from,to,null)
	end

	public void delete(String programName, Token from, Token to) 
		replace(programName,from,to,null)
	end

	public int getLastRewriteTokenIndex() 
		return getLastRewriteTokenIndex(DEFAULT_PROGRAM_NAME)
	end

	protected int getLastRewriteTokenIndex(String programName) 
		Integer I = lastRewriteTokenIndexes.get(programName)
		if ( I==null ) 
			return -1
		end
		return I
	end

	protected void setLastRewriteTokenIndex(String programName, int i) 
		lastRewriteTokenIndexes.put(programName, i)
	end

	protected List<RewriteOperation> getProgram(String name) 
		List<RewriteOperation> is = programs.get(name)
		if ( is==null ) 
			is = initializeProgram(name)
		end
		return is
	end

	private List<RewriteOperation> initializeProgram(String name) 
		List<RewriteOperation> is = new ArrayList<RewriteOperation>(PROGRAM_INIT_SIZE)
		programs.put(name, is)
		return is
	end




	public String getText() 
		return getText(DEFAULT_PROGRAM_NAME, Interval.of(0,tokens.size()-1))
	end




	public String getText(String programName) 
		return getText(programName, Interval.of(0,tokens.size()-1))
	end










	public String getText(Interval interval) 
		return getText(DEFAULT_PROGRAM_NAME, interval)
	end

	public String getText(String programName, Interval interval) 
		List<RewriteOperation> rewrites = programs.get(programName)
		int start = interval.a
		int stop = interval.b

		# ensure start/end are in range
		if ( stop>tokens.size()-1 ) stop = tokens.size()-1
		if ( start<0 ) start = 0

		if ( rewrites==null || rewrites.isEmpty() ) 
			return tokens.getText(interval) # no instructions to execute
		end
		StringBuilder buf = StringBuilder.new()

		# First, optimize instruction stream
		Map<Integer, RewriteOperation> indexToOp = reduceToSingleOperationPerIndex(rewrites)

		# Walk buffer, executing instructions and emitting tokens
		int i = start
		while ( i <= stop && i < tokens.size() ) 
			RewriteOperation op = indexToOp.get(i)
			indexToOp.remove(i) # remove so any left have index size-1
			Token t = tokens.get(i)
			if ( op==null ) 
				# no operation at that index, just dump token
				if ( t.getType()!=Token.EOF ) buf.append(t.getText())
				i++ # move to next token
			end
			else 
				i = op.execute(buf) # execute operation and skip
			end
		end

		# include stuff after end if it's last index in buffer
		# So, if they did an insertAfter(lastValidIndex, "foo"), include
		# foo if end==lastValidIndex.
		if ( stop==tokens.size()-1 ) 
			# Scan any remaining operations after last token
			# should be included (they will be inserts).
			for (RewriteOperation op : indexToOp.values()) 
				if ( op.index >= tokens.size()-1 ) buf.append(op.text)
			end
		end
		return buf.to_s()
	end


















































	protected Map<Integer, RewriteOperation> reduceToSingleOperationPerIndex(List<RewriteOperation> rewrites) 
#		System.out.println("rewrites="+rewrites)

		# WALK REPLACES
		for (int i = 0 i < rewrites.size() i++) 
			RewriteOperation op = rewrites.get(i)
			if ( op==null ) continue
			if ( !(op instanceof ReplaceOp) ) continue
			ReplaceOp rop = (ReplaceOp)rewrites.get(i)
			# Wipe prior inserts within range
			List<? extends InsertBeforeOp> inserts = getKindOfOps(rewrites, InsertBeforeOp.class, i)
			for (InsertBeforeOp iop : inserts) 
				if ( iop.index == rop.index ) 
					# E.g., insert before 2, delete 2..2 update replace
					# text to include insert before, kill insert
					rewrites.set(iop.instructionIndex, null)
					rop.text = iop.text.to_s() + (rop.text!=null?rop.text.to_s():"")
				end
				else if ( iop.index > rop.index && iop.index <= rop.lastIndex ) 
					# delete insert as it's a no-op.
					rewrites.set(iop.instructionIndex, null)
				end
			end
			# Drop any prior replaces contained within
			List<? extends ReplaceOp> prevReplaces = getKindOfOps(rewrites, ReplaceOp.class, i)
			for (ReplaceOp prevRop : prevReplaces) 
				if ( prevRop.index>=rop.index && prevRop.lastIndex <= rop.lastIndex ) 
					# delete replace as it's a no-op.
					rewrites.set(prevRop.instructionIndex, null)
					continue
				end
				# throw exception unless disjoint or identical
				boolean disjoint =
					prevRop.lastIndex<rop.index || prevRop.index > rop.lastIndex
				# Delete special case of replace (text==null):
				# D.i-j.u D.x-y.v	| boundaries overlap	combine to max(min)..max(right)
				if ( prevRop.text==null && rop.text==null && !disjoint ) 
					#System.out.println("overlapping deletes: "+prevRop+", "+rop)
					rewrites.set(prevRop.instructionIndex, null) # kill first delete
					rop.index = Math.min(prevRop.index, rop.index)
					rop.lastIndex = Math.max(prevRop.lastIndex, rop.lastIndex)
					System.out.println("new rop "+rop)
				end
				else if ( !disjoint ) 
					throw new IllegalArgumentException("replace op boundaries of "+rop+" overlap with previous "+prevRop)
				end
			end
		end

		# WALK INSERTS
		for (int i = 0 i < rewrites.size() i++) 
			RewriteOperation op = rewrites.get(i)
			if ( op==null ) continue
			if ( !(op instanceof InsertBeforeOp) ) continue
			InsertBeforeOp iop = (InsertBeforeOp)rewrites.get(i)
			# combine current insert with prior if any at same index
			List<? extends InsertBeforeOp> prevInserts = getKindOfOps(rewrites, InsertBeforeOp.class, i)
			for (InsertBeforeOp prevIop : prevInserts) 
				if ( prevIop.index==iop.index ) 
					if ( InsertAfterOp.class.isInstance(prevIop) ) 
						iop.text = catOpText(prevIop.text, iop.text)
						rewrites.set(prevIop.instructionIndex, null)
					end
					else if ( InsertBeforeOp.class.isInstance(prevIop) )  # combine objects
						# convert to strings...we're in process of toString'ing
						# whole token buffer so no lazy eval issue with any templates
						iop.text = catOpText(iop.text, prevIop.text)
						# delete redundant prior insert
						rewrites.set(prevIop.instructionIndex, null)
					end
				end
			end
			# look for replaces where iop.index is in range error
			List<? extends ReplaceOp> prevReplaces = getKindOfOps(rewrites, ReplaceOp.class, i)
			for (ReplaceOp rop : prevReplaces) 
				if ( iop.index == rop.index ) 
					rop.text = catOpText(iop.text,rop.text)
					rewrites.set(i, null)	# delete current insert
					continue
				end
				if ( iop.index >= rop.index && iop.index <= rop.lastIndex ) 
					throw new IllegalArgumentException("insert op "+iop+" within boundaries of previous "+rop)
				end
			end
		end
		# System.out.println("rewrites after="+rewrites)
		Map<Integer, RewriteOperation> m = new HashMap<Integer, RewriteOperation>()
		for (int i = 0 i < rewrites.size() i++) 
			RewriteOperation op = rewrites.get(i)
			if ( op==null ) continue # ignore deleted ops
			if ( m.get(op.index)!=null ) 
				throw new Error("should only be one op per index")
			end
			m.put(op.index, op)
		end
		#System.out.println("index to op: "+m)
		return m
	end

	protected String catOpText(Object a, Object b) 
		String x = ""
		String y = ""
		if ( a!=null ) x = a.to_s()
		if ( b!=null ) y = b.to_s()
		return x+y
	end


	protected <T extends RewriteOperation> List<? extends T> getKindOfOps(List<? extends RewriteOperation> rewrites, Class<T> kind, int before) 
		List<T> ops = new ArrayList<T>()
		for (int i=0 i<before && i<rewrites.size() i++) 
			RewriteOperation op = rewrites.get(i)
			if ( op==null ) continue # ignore deleted
			if ( kind.isInstance(op) ) 
				ops.add(kind.cast(op))
			end
		end
		return ops
	end
end
