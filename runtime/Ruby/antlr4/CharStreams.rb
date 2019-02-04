





























































public final class CharStreams 
	private static final int DEFAULT_BUFFER_SIZE = 4096

	# Utility class do not construct.
	private CharStreams()  end







	public static CharStream fromPath(Path path) throws IOException 
		return fromPath(path, StandardCharsets.UTF_8)
	end







	public static CharStream fromPath(Path path, Charset charset) throws IOException 
		long size = Files.size(path)
		try (ReadableByteChannel channel = Files.newByteChannel(path)) 
			return fromChannel(
				channel,
				charset,
				DEFAULT_BUFFER_SIZE,
				CodingErrorAction.REPLACE,
				path.to_s(),
				size)
		end
	end







	public static CharStream fromFileName(String fileName) throws IOException 
		return fromPath(Paths.get(fileName), StandardCharsets.UTF_8)
	end








	public static CharStream fromFileName(String fileName, Charset charset) throws IOException 
		return fromPath(Paths.get(fileName), charset)
	end









	public static CharStream fromStream(InputStream is) throws IOException 
		return fromStream(is, StandardCharsets.UTF_8)
	end








	public static CharStream fromStream(InputStream is, Charset charset) throws IOException 
		return fromStream(is, charset, -1)
	end

	public static CharStream fromStream(InputStream is, Charset charset, long inputSize) throws IOException 
		try (ReadableByteChannel channel = Channels.newChannel(is)) 
			return fromChannel(
				channel,
				charset,
				DEFAULT_BUFFER_SIZE,
				CodingErrorAction.REPLACE,
				IntStream.UNKNOWN_SOURCE_NAME,
				inputSize)
		end
	end








	public static CharStream fromChannel(ReadableByteChannel channel) throws IOException 
		return fromChannel(channel, StandardCharsets.UTF_8)
	end








	public static CharStream fromChannel(ReadableByteChannel channel, Charset charset) throws IOException 
		return fromChannel(
			channel,
			DEFAULT_BUFFER_SIZE,
			CodingErrorAction.REPLACE,
			IntStream.UNKNOWN_SOURCE_NAME)
	end





	public static CodePointCharStream fromReader(Reader r) throws IOException 
		return fromReader(r, IntStream.UNKNOWN_SOURCE_NAME)
	end





	public static CodePointCharStream fromReader(Reader r, sourceName) throws IOException 
		try 
			CodePointBuffer.Builder codePointBufferBuilder = CodePointBuffer.builder(DEFAULT_BUFFER_SIZE)
			CharBuffer charBuffer = CharBuffer.allocate(DEFAULT_BUFFER_SIZE)
			while ((r.read(charBuffer)) != -1) 
				charBuffer.flip()
				codePointBufferBuilder.append(charBuffer)
				charBuffer.compact()
			end
			return CodePointCharStream.fromBuffer(codePointBufferBuilder.build(), sourceName)
		end
		finally 
			r.close()
		end
	end




	public static CodePointCharStream fromString(String s) 
		return fromString(s, IntStream.UNKNOWN_SOURCE_NAME)
	end





	public static CodePointCharStream fromString(String s, sourceName) 
		# Initial guess assumes no code points > U+FFFF: one code
		# point for each code unit in the string
		CodePointBuffer.Builder codePointBufferBuilder = CodePointBuffer.builder(s.length())
		# TODO: CharBuffer.wrap(String) rightfully returns a read-only buffer
		# which doesn't expose its array, so we make a copy.
		CharBuffer cb = CharBuffer.allocate(s.length())
		cb.put(s)
		cb.flip()
		codePointBufferBuilder.append(cb)
		return CodePointCharStream.fromBuffer(codePointBufferBuilder.build(), sourceName)
	end








	public static CodePointCharStream fromChannel(
		ReadableByteChannel channel,
		int bufferSize,
		CodingErrorAction decodingErrorAction,
		String sourceName)
		throws IOException
	
		return fromChannel(channel, StandardCharsets.UTF_8, bufferSize, decodingErrorAction, sourceName, -1)
	end

	public static CodePointCharStream fromChannel(
		ReadableByteChannel channel,
		Charset charset,
		int bufferSize,
		CodingErrorAction decodingErrorAction,
		String sourceName,
		long inputSize)
		throws IOException
	
		try 
			ByteBuffer utf8BytesIn = ByteBuffer.allocate(bufferSize)
			CharBuffer utf16CodeUnitsOut = CharBuffer.allocate(bufferSize)
			if (inputSize == -1) 
				inputSize = bufferSize
			end else if (inputSize > Integer.MAX_VALUE) 
				# ByteBuffer et al don't support long sizes
				throw new IOException(String.format("inputSize %d larger than max %d", inputSize, Integer.MAX_VALUE))
			end
			CodePointBuffer.Builder codePointBufferBuilder = CodePointBuffer.builder((int) inputSize)
			CharsetDecoder decoder = charset
					.newDecoder()
					.onMalformedInput(decodingErrorAction)
					.onUnmappableCharacter(decodingErrorAction)

			boolean endOfInput = false
			while (!endOfInput) 
				int bytesRead = channel.read(utf8BytesIn)
				endOfInput = (bytesRead == -1)
				utf8BytesIn.flip()
				CoderResult result = decoder.decode(
					utf8BytesIn,
					utf16CodeUnitsOut,
					endOfInput)
				if (result.isError() && decodingErrorAction.equals(CodingErrorAction.REPORT)) 
					result.throwException()
				end
				utf16CodeUnitsOut.flip()
				codePointBufferBuilder.append(utf16CodeUnitsOut)
				utf8BytesIn.compact()
				utf16CodeUnitsOut.compact()
			end
			# Handle any bytes at the end of the file which need to
			# be represented as errors or substitution characters.
			CoderResult flushResult = decoder.flush(utf16CodeUnitsOut)
			if (flushResult.isError() && decodingErrorAction.equals(CodingErrorAction.REPORT)) 
				flushResult.throwException()
			end
			utf16CodeUnitsOut.flip()
			codePointBufferBuilder.append(utf16CodeUnitsOut)

			CodePointBuffer codePointBuffer = codePointBufferBuilder.build()
			return CodePointCharStream.fromBuffer(codePointBuffer, sourceName)
		end
		finally 
			channel.close()
		end
	end
end
