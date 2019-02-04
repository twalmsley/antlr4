require '../../antlr4/runtime/Ruby/antlr4/IntegerList'


class IntegerStack < IntegerList

  def initialize(list = nil)
    super(list)
  end

  def push(value)
    add(value)
  end

  def pop()
    return removeAt(size() - 1)
  end

  def peek()
    return get(size() - 1)
  end

end
