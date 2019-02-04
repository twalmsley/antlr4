



















public abstract class CodePointTransitions 




	public static Transition createWithCodePoint(ATNState target, int codePoint) 
		if (Character.isSupplementaryCodePoint(codePoint)) 
			return new SetTransition(target, IntervalSet.of(codePoint))
		end
		else 
			return new AtomTransition(target, codePoint)
		end
	end






	public static Transition createWithCodePointRange(
			ATNState target,
			int codePointFrom,
			int codePointTo) 
		if (Character.isSupplementaryCodePoint(codePointFrom) ||
		    Character.isSupplementaryCodePoint(codePointTo)) 
			return new SetTransition(target, IntervalSet.of(codePointFrom, codePointTo))
		end
		else 
			return new RangeTransition(target, codePointFrom, codePointTo)
		end
	end
end
