class CommonTokenFactory


  DEFAULT = CommonTokenFactory.new


  @copyText = false


  def initialize(copyText = false)
    @copyText = copyText
  end


  def create(source, type, text,
             channel, start, stop,
             line, charPositionInLine)

    t = CommonToken.new(source, type, channel, start, stop)
    t.setLine(line)
    t.setCharPositionInLine(charPositionInLine)
    if (text != nil)
      t.setText(text)
    elsif (copyText && source.b != nil)
      t.setText(source.b.getText(Interval.of(start, stop)))
    end

    return t
  end


  def createSimple(type, text)
    return CommonToken.new(type, text)
  end
end
