




























public abstract class SemanticContext 




    public static final SemanticContext NONE = new Predicate()














    public abstract boolean eval(Recognizer<?,?> parser, RuleContext parserCallStack)



















	public SemanticContext evalPrecedence(Recognizer<?,?> parser, RuleContext parserCallStack) 
		return this
	end

    public static class Predicate extends SemanticContext 
        public final int ruleIndex
       	public final int predIndex
       	public final boolean isCtxDependent  # e.g., $i ref in pred

        protected Predicate() 
            this.ruleIndex = -1
            this.predIndex = -1
            this.isCtxDependent = false
        end

        public Predicate(int ruleIndex, int predIndex, boolean isCtxDependent) 
            this.ruleIndex = ruleIndex
            this.predIndex = predIndex
            this.isCtxDependent = isCtxDependent
        end

        
        public boolean eval(Recognizer<?,?> parser, RuleContext parserCallStack) 
            RuleContext localctx = isCtxDependent ? parserCallStack : null
            return parser.sempred(localctx, ruleIndex, predIndex)
        end

		
		public int hashCode() 
			int hashCode = MurmurHash.initialize()
			hashCode = MurmurHash.update(hashCode, ruleIndex)
			hashCode = MurmurHash.update(hashCode, predIndex)
			hashCode = MurmurHash.update(hashCode, isCtxDependent ? 1 : 0)
			hashCode = MurmurHash.finish(hashCode, 3)
			return hashCode
		end

		
		public boolean equals(Object obj) 
			if ( !(obj instanceof Predicate) ) return false
			if ( this == obj ) return true
			Predicate p = (Predicate)obj
			return this.ruleIndex == p.ruleIndex &&
				   this.predIndex == p.predIndex &&
				   this.isCtxDependent == p.isCtxDependent
		end

		
		public String toString() 
            return ""+ruleIndex+":"+predIndex+"end?"
        end
    end

	public static class PrecedencePredicate extends SemanticContext implements Comparable<PrecedencePredicate> 
		public final int precedence

		protected PrecedencePredicate() 
			this.precedence = 0
		end

		public PrecedencePredicate(int precedence) 
			this.precedence = precedence
		end

		
		public boolean eval(Recognizer<?, ?> parser, RuleContext parserCallStack) 
			return parser.precpred(parserCallStack, precedence)
		end

		
		public SemanticContext evalPrecedence(Recognizer<?, ?> parser, RuleContext parserCallStack) 
			if (parser.precpred(parserCallStack, precedence)) 
				return SemanticContext.NONE
			end
			else 
				return null
			end
		end

		
		public int compareTo(PrecedencePredicate o) 
			return precedence - o.precedence
		end

		
		public int hashCode() 
			int hashCode = 1
			hashCode = 31 * hashCode + precedence
			return hashCode
		end

		
		public boolean equals(Object obj) 
			if (!(obj instanceof PrecedencePredicate)) 
				return false
			end

			if (this == obj) 
				return true
			end

			PrecedencePredicate other = (PrecedencePredicate)obj
			return this.precedence == other.precedence
		end

		
		# precedence >= _precedenceStack.peek()
		public String toString() 
			return ""+precedence+">=precend?"
		end
	end







	public static abstract class Operator extends SemanticContext 









		public abstract Collection<SemanticContext> getOperands()
	end





    public static class AND extends Operator 
		public final SemanticContext[] opnds

		public AND(SemanticContext a, SemanticContext b) 
			Set<SemanticContext> operands = new HashSet<SemanticContext>()
			if ( a instanceof AND ) operands.addAll(Arrays.asList(((AND)a).opnds))
			else operands.add(a)
			if ( b instanceof AND ) operands.addAll(Arrays.asList(((AND)b).opnds))
			else operands.add(b)

			List<PrecedencePredicate> precedencePredicates = filterPrecedencePredicates(operands)
			if (!precedencePredicates.isEmpty()) 
				# interested in the transition with the lowest precedence
				PrecedencePredicate reduced = Collections.min(precedencePredicates)
				operands.add(reduced)
			end

			opnds = operands.toArray(new SemanticContext[operands.size()])
        end

		
		public Collection<SemanticContext> getOperands() 
			return Arrays.asList(opnds)
		end

		
		public boolean equals(Object obj) 
			if ( this==obj ) return true
			if ( !(obj instanceof AND) ) return false
			AND other = (AND)obj
			return Arrays.equals(this.opnds, other.opnds)
		end

		
		public int hashCode() 
			return MurmurHash.hashCode(opnds, AND.class.hashCode())
		end








		
		public boolean eval(Recognizer<?,?> parser, RuleContext parserCallStack) 
			for (SemanticContext opnd : opnds) 
				if ( !opnd.eval(parser, parserCallStack) ) return false
			end
			return true
        end

		
		public SemanticContext evalPrecedence(Recognizer<?, ?> parser, RuleContext parserCallStack) 
			boolean differs = false
			List<SemanticContext> operands = new ArrayList<SemanticContext>()
			for (SemanticContext context : opnds) 
				SemanticContext evaluated = context.evalPrecedence(parser, parserCallStack)
				differs |= (evaluated != context)
				if (evaluated == null) 
					# The AND context is false if any element is false
					return null
				end
				else if (evaluated != NONE) 
					# Reduce the result by skipping true elements
					operands.add(evaluated)
				end
			end

			if (!differs) 
				return this
			end

			if (operands.isEmpty()) 
				# all elements were true, so the AND context is true
				return NONE
			end

			SemanticContext result = operands.get(0)
			for (int i = 1 i < operands.size() i++) 
				result = SemanticContext.and(result, operands.get(i))
			end

			return result
		end

		
		public String toString() 
			return Utils.join(Arrays.asList(opnds).iterator(), "&&")
        end
    end





    public static class OR extends Operator 
		public final SemanticContext[] opnds

		public OR(SemanticContext a, SemanticContext b) 
			Set<SemanticContext> operands = new HashSet<SemanticContext>()
			if ( a instanceof OR ) operands.addAll(Arrays.asList(((OR)a).opnds))
			else operands.add(a)
			if ( b instanceof OR ) operands.addAll(Arrays.asList(((OR)b).opnds))
			else operands.add(b)

			List<PrecedencePredicate> precedencePredicates = filterPrecedencePredicates(operands)
			if (!precedencePredicates.isEmpty()) 
				# interested in the transition with the highest precedence
				PrecedencePredicate reduced = Collections.max(precedencePredicates)
				operands.add(reduced)
			end

			this.opnds = operands.toArray(new SemanticContext[operands.size()])
        end

		
		public Collection<SemanticContext> getOperands() 
			return Arrays.asList(opnds)
		end

		
		public boolean equals(Object obj) 
			if ( this==obj ) return true
			if ( !(obj instanceof OR) ) return false
			OR other = (OR)obj
			return Arrays.equals(this.opnds, other.opnds)
		end

		
		public int hashCode() 
			return MurmurHash.hashCode(opnds, OR.class.hashCode())
		end








		
        public boolean eval(Recognizer<?,?> parser, RuleContext parserCallStack) 
			for (SemanticContext opnd : opnds) 
				if ( opnd.eval(parser, parserCallStack) ) return true
			end
			return false
        end

		
		public SemanticContext evalPrecedence(Recognizer<?, ?> parser, RuleContext parserCallStack) 
			boolean differs = false
			List<SemanticContext> operands = new ArrayList<SemanticContext>()
			for (SemanticContext context : opnds) 
				SemanticContext evaluated = context.evalPrecedence(parser, parserCallStack)
				differs |= (evaluated != context)
				if (evaluated == NONE) 
					# The OR context is true if any element is true
					return NONE
				end
				else if (evaluated != null) 
					# Reduce the result by skipping false elements
					operands.add(evaluated)
				end
			end

			if (!differs) 
				return this
			end

			if (operands.isEmpty()) 
				# all elements were false, so the OR context is false
				return null
			end

			SemanticContext result = operands.get(0)
			for (int i = 1 i < operands.size() i++) 
				result = SemanticContext.or(result, operands.get(i))
			end

			return result
		end

        
        public String toString() 
			return Utils.join(Arrays.asList(opnds).iterator(), "||")
        end
    end

	public static SemanticContext and(SemanticContext a, SemanticContext b) 
		if ( a == null || a == NONE ) return b
		if ( b == null || b == NONE ) return a
		AND result = new AND(a, b)
		if (result.opnds.length == 1) 
			return result.opnds[0]
		end

		return result
	end





	public static SemanticContext or(SemanticContext a, SemanticContext b) 
		if ( a == null ) return b
		if ( b == null ) return a
		if ( a == NONE || b == NONE ) return NONE
		OR result = new OR(a, b)
		if (result.opnds.length == 1) 
			return result.opnds[0]
		end

		return result
	end

	private static List<PrecedencePredicate> filterPrecedencePredicates(Collection<? extends SemanticContext> collection) 
		ArrayList<PrecedencePredicate> result = null
		for (Iterator<? extends SemanticContext> iterator = collection.iterator() iterator.hasNext() ) 
			SemanticContext context = iterator.next()
			if (context instanceof PrecedencePredicate) 
				if (result == null) 
					result = new ArrayList<PrecedencePredicate>()
				end

				result.add((PrecedencePredicate)context)
				iterator.remove()
			end
		end

		if (result == null) 
			return Collections.emptyList()
		end

		return result
	end
end
