require '../antlr4/DefaultErrorStrategy'

class BailErrorStrategy < DefaultErrorStrategy


  def recover(recognizer, e)
    context = recognizer.getContext()
    while context != nil
      context = context.getParent()
      context.exception = e
    end

    raise ParseCancellationException(e)
  end


  def recoverInline(recognizer)

    e = InputMismatchException.new (recognizer)
    context = recognizer.getContext()
    while context != nil
      context = context.getParent()
      context.exception = e
    end

    raise ParseCancellationException(e)
  end


  def sync(recognizer)
  end
end
