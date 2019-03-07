class DoubleKeyMap
  def initialize
    @data = Hash.new
  end

  def put(k1, k2, v)
    data2 = @data[k1]
    prev = nil
    if (data2 == nil)
      data2 = Hash.new
      @data[k1] = data2
    else
      prev = data2[k2]
    end
    data2[k2] = v
    return prev
  end

  def get2(k1, k2)
    data2 = @data[k1]
    if (data2 == nil)
      return nil
    end
    return data2[k2]
  end

  def get1(k1)
    return @data.get(k1)
  end


  def values(k1)
    data2 = @data.get(k1)
    if (data2 == nil)
      return nil
    end
    return data2.values
  end


  def keySet0()
    return @data.keySet()
  end


  def keySet1(k1)
    data2 = @data[k1]
    if (data2 == nil)
      return nil
    end
    return data2.keySet()
  end
end
