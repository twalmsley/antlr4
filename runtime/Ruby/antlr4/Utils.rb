




















class Utils 

	def self.numNonnull(data)
		int n = 0
		if ( data == null ) return n
		for (Object o : data) 
			if ( o!=null ) n++
		end
		return n
	end

	def self.removeAllElements(Collection<T> data, T value) 
		if ( data==null ) return
		while ( data.contains(value) ) data.remove(value)
	end

	def self.escapeWhitespace(String s, boolean escapeSpaces) 
		StringBuilder buf = StringBuilder.new()
		for (char c : s.toCharArray()) 
			if ( c==' ' && escapeSpaces ) buf.append('\u00B7')
			else if ( c=='\t' ) buf.append("\\t")
			else if ( c=='\n' ) buf.append("\\n")
			else if ( c=='\r' ) buf.append("\\r")
			else buf.append(c)
		end
		return buf.to_s()
	end

	def self.writeFile(String fileName, content) throws IOException 
		writeFile(fileName, content, null)
	end

	def self.writeFile(String fileName, content, encoding) throws IOException 
		File f = new File(fileName)
		FileOutputStream fos = new FileOutputStream(f)
		OutputStreamWriter osw
		if (encoding != null) 
			osw = new OutputStreamWriter(fos, encoding)
		end
		else 
			osw = new OutputStreamWriter(fos)
		end

		try 
			osw.write(content)
		end
		finally 
			osw.close()
		end
	end


	def self.readFile(fileName) throws IOException
		return readFile(fileName, null)
	end


	def self.readFile(fileName, encoding) throws IOException
		File f = new File(fileName)
		int size = (int)f.length()
		InputStreamReader isr
		FileInputStream fis = new FileInputStream(fileName)
		if ( encoding!=null ) 
			isr = new InputStreamReader(fis, encoding)
		end
		else 
			isr = new InputStreamReader(fis)
		end
		char[] data = null
		try 
			data = new char[size]
			int n = isr.read(data)
			if (n < data.length) 
				data = Arrays.copyOf(data, n)
			end
		end
		finally 
			isr.close()
		end
		return data
	end




	public static Map<String, Integer> toMap(String[] keys) 
		Map<String, Integer> m = new HashMap<String, Integer>()
		for (int i=0 i<keys.length i++) 
			m.put(keys[i], i)
		end
		return m
	end

	def self.toCharArray(IntegerList data) 
		if ( data==null ) return null
		return data.toCharArray()
	end

	public static IntervalSet toSet(BitSet bits) 
		IntervalSet s = new IntervalSet()
		int i = bits.nextSetBit(0)
		while ( i >= 0 ) 
			s.add(i)
			i = bits.nextSetBit(i+1)
		end
		return s
	end


	def self.expandTabs(String s, int tabSize) 
		if ( s==null ) return null
		StringBuilder buf = StringBuilder.new()
		int col = 0
		for (int i = 0 i<s.length() i++) 
			char c = s.charAt(i)
			switch ( c ) 
				case '\n' :
					col = 0
					buf.append(c)
					break
				case '\t' :
					int n = tabSize-col%tabSize
					col+=n
					buf.append(spaces(n))
					break
				default :
					col++
					buf.append(c)
					break
			end
		end
		return buf.to_s()
	end


	def self.spaces(int n) 
		return sequence(n, " ")
	end


	def self.newlines(int n) 
		return sequence(n, "\n")
	end


	def self.sequence(int n, s) 
		StringBuilder buf = StringBuilder.new()
		for (int sp=1 sp<=n sp++) buf.append(s)
		return buf.to_s()
	end


	def self.count(String s, char x) 
		int n = 0
		for (int i = 0 i<s.length() i++) 
			if ( s.charAt(i)==x ) 
				n++
			end
		end
		return n
	end
end
