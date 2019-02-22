require '../../antlr4/runtime/Ruby/antlr4/CommonToken'

class CommonTokenFactory


  DEFAULT = CommonTokenFactory.new


  @copyText = false


  def initialize(copyText = false)
    @copyText = copyText
  end


  def create(source, type, text,
             channel, start, stop,
             line, charPositionInLine)

    t = CommonToken.create_1(source, type, channel, start, stop)
    t.line = line
    t.charPositionInLine = charPositionInLine
    if (text != nil)
      t.text = text
    elsif (@copyText && source.b != nil)
      t.setText(source.b.getText(Interval.of(start, stop)))
    end

    return t
  end


  def createSimple(type, text)
    return CommonToken.create_2(type, text)
  end
end
