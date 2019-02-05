require '../../antlr4/runtime/Ruby/antlr4/PredictionContext'

class PredictionContextCache
  @cache = Hash.new


  def add(ctx)
    if (ctx == PredictionContext.EMPTY)
      return PredictionContext.EMPTY
    end
    existing = @cache.get(ctx)
    if (existing != nil)
      return existing
    end
    @cache.put(ctx, ctx)
    return ctx
  end

  def get(ctx)
    return @cache.get(ctx)
  end

  def size()
    return @cache.size()
  end
end
