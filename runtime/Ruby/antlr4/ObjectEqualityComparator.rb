require 'singleton'

class ObjectEqualityComparator
  include Singleton

  def hash(obj)
    if (obj == nil)
      return 0
    end

    return obj.hash()
  end


  def equals(a, b)
    if (a == nil)
      return b == nil
    end

    return a.eql?(b)
  end

end
