class Triple
  attr_accessor :a
  attr_accessor :b
  attr_accessor :c

  def initialize(a, b, c)
    @a = a
    @b = b
    @c = c
  end


  def eql?(obj)
    if (obj == self)
      return true
    else
      if (!(obj.is_a? Triple))
        return false
      end
    end

    return ObjectEqualityComparator.instance.equals(a, obj.a) && ObjectEqualityComparator.instance.equals(b, obj.b) && ObjectEqualityComparator.instance.equals(c, obj.c)
  end

  def hash()
    hashcode = 0
    hashcode = MurmurHash.update_obj(hashcode, a)
    hashcode = MurmurHash.update_obj(hashcode, b)
    hashcode = MurmurHash.update_obj(hashcode, c)
    return MurmurHash.finish(hashcode, 3)
  end

  def to_s()
    return "(" << @a.to_s << "," << @b.to_s << ", " << @c.to_s << ")"
  end
end
