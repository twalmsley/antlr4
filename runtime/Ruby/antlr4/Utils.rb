class Utils

  def self.numNonnull(data)
    n = 0
    if (data == nil)
      return n
    end
    data.each do |o|
      if (o != nil)
        n += 1
      end
    end
    return n
  end

  def self.removeAllElements(data, value)
    if (data == nil)
      return
    end
    while (data.contains(value))
      data.remove(value)
    end
  end

  def self.escapeWhitespace(s, escapeSpaces)
    buf = ""
    s.each_char do |c|
      if (c == ' ' && escapeSpaces)
        buf << '\u00B7'
      elsif (c == '\t')
        buf << "\\t"
      elsif (c == '\n')
        buf << "\\n"
      elsif (c == '\r')
        buf << "\\r"
      else
        buf << c
      end
    end
    return buf
  end

  def self.writeFile(fileName, content, encoding = nil)
    f = File.new(fileName, "w")

    begin
      f << content
    ensure
      f.close()
    end
  end

  def self.readFile(fileName, encoding = nil)
    f = File.new(fileName, "r")
    size = File.size(fileName)

    begin
      data = Array.new(size)
      f.read(nil, data)
    ensure
      f.close()
    end

    return data
  end


  def self.expandTabs(s, tabSize)
    if (s == nil)
      return nil
    end
    buf = ""
    col = 0
    i = 0
    while i < s.length()
      c = s[i]
      case (c)
      when '\n'
        col = 0
        buf << c
      when '\t'
        n = tabSize - col % tabSize
        col += n
        buf << spaces(n)
      else
        col += 1
        buf << c
      end
      i += 1
    end
    return buf
  end


  def self.spaces(n)
    return sequence(n, " ")
  end

  def self.newlines(n)
    return sequence(n, "\n")
  end

  def self.sequence(n, s)
    buf = ""
    sp = 1
    while sp <= n
      buf << s
      sp += 1
    end
    return buf
  end


  def self.count(s, x)
    n = 0
    i = 0
    while i < s.length()
      if (s[i] == x)
        n += 1
      end
      i += 1
    end
    return n
  end
end
