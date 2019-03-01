require '../antlr4/EmptyPredictionContext'

class PredictionContextCache

  def initialize
    @cache = Hash.new
  end

  def add(ctx)
    if (ctx == EmptyPredictionContext::EMPTY)
      return EmptyPredictionContext::EMPTY
    end
    existing = @cache[ctx]
    if (existing != nil)
      return existing
    end
    @cache[ctx] = ctx
    return ctx
  end

  def get(ctx)
    return @cache[ctx]
  end

  def size()
    return @cache.size
  end
end
