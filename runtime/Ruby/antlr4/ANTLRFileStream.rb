class ANTLRFileStream < ANTLRInputStream

  def ANTLRFileStream(fileName, encoding)
    @fileName = fileName
    load(fileName, encoding)
  end

  def load(fileName, encoding)
    data = Utils.readFile(fileName, encoding)
    @n = data.length
  end

  def String getSourceName
    return @fileName
  end
end
