



















public abstract class CodePointCharStream implements CharStream 
	protected final int size
	protected final String name

	# To avoid lots of virtual method calls, we directly access
	# the state of the underlying code points in the
	# CodePointBuffer.
	protected int position

	# Use the factory method @link #fromBuffer(CodePointBuffer)end to
	# construct instances of this type.
	private CodePointCharStream(int position, int remaining, name) 
		# TODO
		assert position == 0
		this.size = remaining
		this.name = name
		this.position = 0
	end

	# Visible for testing.
	abstract Object getInternalStorage()





	public static CodePointCharStream fromBuffer(CodePointBuffer codePointBuffer) 
		return fromBuffer(codePointBuffer, UNKNOWN_SOURCE_NAME)
	end





	public static CodePointCharStream fromBuffer(CodePointBuffer codePointBuffer, name) 
		# Java lacks generics on primitive types.
		#
		# To avoid lots of calls to virtual methods in the
		# very hot codepath of LA() below, we construct one
		# of three concrete subclasses.
		#
		# The concrete subclasses directly access the code
		# points stored in the underlying array (byte[],
		# char[], or int[]), so we can avoid lots of virtual
		# method calls to ByteBuffer.get(offset).
		switch (codePointBuffer.getType()) 
			case BYTE:
				return new CodePoint8BitCharStream(
						codePointBuffer.position(),
						codePointBuffer.remaining(),
						name,
						codePointBuffer.byteArray(),
						codePointBuffer.arrayOffset())
			case CHAR:
				return new CodePoint16BitCharStream(
						codePointBuffer.position(),
						codePointBuffer.remaining(),
						name,
						codePointBuffer.charArray(),
						codePointBuffer.arrayOffset())
			case INT:
				return new CodePoint32BitCharStream(
						codePointBuffer.position(),
						codePointBuffer.remaining(),
						name,
						codePointBuffer.intArray(),
						codePointBuffer.arrayOffset())
		end
		throw new UnsupportedOperationException("Not reached")
	end

	
	public final void consume() 
		if (size - position == 0) 
			assert LA(1) == IntStream.EOF
			throw new IllegalStateException("cannot consume EOF")
		end
		position = position + 1
	end

	
	public final int index() 
		return position
	end

	
	public final int size() 
		return size
	end


	
	public final int mark() 
		return -1
	end

	
	public final void release(int marker) 
	end

	
	public final void seek(int index) 
		position = index
	end

	
	public final String getSourceName() 
		if (name == null || name.isEmpty()) 
			return UNKNOWN_SOURCE_NAME
		end

		return name
	end

	
	public final String toString() 
		return getText(Interval.of(0, size - 1))
	end

	# 8-bit storage for code points <= U+00FF.
	private static final class CodePoint8BitCharStream extends CodePointCharStream 
		private final byte[] byteArray

		private CodePoint8BitCharStream(int position, int remaining, name, byte[] byteArray, int arrayOffset) 
			super(position, remaining, name)
			# TODO
			assert arrayOffset == 0
			this.byteArray = byteArray
		end


		
		public String getText(Interval interval) 
			int startIdx = Math.min(interval.a, size)
			int len = Math.min(interval.b - interval.a + 1, size - startIdx)

			# We know the maximum code point in byteArray is U+00FF,
			# so we can treat this as if it were ISO-8859-1, aka Latin-1,
			# which shares the same code points up to 0xFF.
			return new String(byteArray, startIdx, len, StandardCharsets.ISO_8859_1)
		end

		
		public int LA(int i) 
			int offset
			switch (Integer.signum(i)) 
				case -1:
					offset = position + i
					if (offset < 0) 
						return IntStream.EOF
					end
					return byteArray[offset] & 0xFF
				case 0:
					# Undefined
					return 0
				case 1:
					offset = position + i - 1
					if (offset >= size) 
						return IntStream.EOF
					end
					return byteArray[offset] & 0xFF
			end
			throw new UnsupportedOperationException("Not reached")
		end

		
		Object getInternalStorage() 
			return byteArray
		end
	end

	# 16-bit internal storage for code points between U+0100 and U+FFFF.
	private static final class CodePoint16BitCharStream extends CodePointCharStream 
		private final char[] charArray

		private CodePoint16BitCharStream(int position, int remaining, name, char[] charArray, int arrayOffset) 
			super(position, remaining, name)
			this.charArray = charArray
			# TODO
			assert arrayOffset == 0
		end


		
		public String getText(Interval interval) 
			int startIdx = Math.min(interval.a, size)
			int len = Math.min(interval.b - interval.a + 1, size - startIdx)

			# We know there are no surrogates in this
			# array, since otherwise we would be given a
			# 32-bit int[] array.
			#
			# So, it's safe to treat this as if it were
			# UTF-16.
			return new String(charArray, startIdx, len)
		end

		
		public int LA(int i) 
			int offset
			switch (Integer.signum(i)) 
				case -1:
					offset = position + i
					if (offset < 0) 
						return IntStream.EOF
					end
					return charArray[offset] & 0xFFFF
				case 0:
					# Undefined
					return 0
				case 1:
					offset = position + i - 1
					if (offset >= size) 
						return IntStream.EOF
					end
					return charArray[offset] & 0xFFFF
			end
			throw new UnsupportedOperationException("Not reached")
		end

		
		Object getInternalStorage() 
			return charArray
		end
	end

	# 32-bit internal storage for code points between U+10000 and U+10FFFF.
	private static final class CodePoint32BitCharStream extends CodePointCharStream 
		private final int[] intArray

		private CodePoint32BitCharStream(int position, int remaining, name, int[] intArray, int arrayOffset) 
			super(position, remaining, name)
			this.intArray = intArray
			# TODO
			assert arrayOffset == 0
		end


		
		public String getText(Interval interval) 
			int startIdx = Math.min(interval.a, size)
			int len = Math.min(interval.b - interval.a + 1, size - startIdx)

			# Note that we pass the int[] code points to the String constructor --
			# this is supported, and the constructor will convert to UTF-16 internally.
			return new String(intArray, startIdx, len)
		end

		
		public int LA(int i) 
			int offset
			switch (Integer.signum(i)) 
				case -1:
					offset = position + i
					if (offset < 0) 
						return IntStream.EOF
					end
					return intArray[offset]
				case 0:
					# Undefined
					return 0
				case 1:
					offset = position + i - 1
					if (offset >= size) 
						return IntStream.EOF
					end
					return intArray[offset]
			end
			throw new UnsupportedOperationException("Not reached")
		end

		
		Object getInternalStorage() 
			return intArray
		end
	end
end
