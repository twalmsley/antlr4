require 'ostruct'
require '../antlr4/Token'

class CommonToken

  EMPTY_SOURCE = OpenStruct.new

  attr_accessor :type
  attr_accessor :line
  attr_accessor :charPositionInLine
  attr_accessor :channel
  attr_accessor :source
  attr_accessor :text
  attr_accessor :index
  attr_accessor :start
  attr_accessor :stop


  def initialize(type = nil)
    @charPositionInLine = -1
    @channel = Token::DEFAULT_CHANNEL
    @index = -1
    @type = type
    @source = EMPTY_SOURCE
    @text = nil
  end

  def self.create_1(source, type, channel, start, stop)
    result = CommonToken.new(type)
    result.source = source
    result.channel = channel
    result.start = start
    result.stop = stop
    if (source.a != nil)
      result.line = source.a.getLine()
      result.charPositionInLine = source.a.getCharPositionInLine()
    end
    result
  end

  def self.create_2(type, text)
    result = CommonToken.new(type)
    result.text = text
    result
  end

  def create_3(oldToken)
    result = CommonToken.new(oldToken.getType())

    result.line = oldToken.getLine()
    result.index = oldToken.getTokenIndex()
    result.charPositionInLine = oldToken.getCharPositionInLine()
    result.channel = oldToken.getChannel()
    result.start = oldToken.getStartIndex()
    result.stop = oldToken.getStopIndex()

    if (oldToken.is_a? CommonToken)
      result.text = oldToken.text
      result.source = oldToken.source
    else
      result.text = oldToken.getText()
      result.source = OpenStruct.new
      result.source.a = oldToken.getTokenSource()
      result.source.b = oldToken.getInputStream()
    end
    result
  end

  def getInputStream
    @source.b
  end

  def getText()
    if (@text != nil)
      return @text
    end

    input = getInputStream()
    if (input == nil)
      return nil
    end
    n = input.size()
    if (@start < n && @stop < n)
      return input.getText(Interval.of(@start, @stop))
    else
      return "<EOF>"
    end
  end


  def toString_recog(r = nil)

    channelStr = ""
    if (@channel > 0)
      channelStr = ",channel=" + @channel.to_s
    end
    txt = getText()
    if (txt != nil)
      txt = txt.replace("\n", "\\n")
      txt = txt.replace("\r", "\\r")
      txt = txt.replace("\t", "\\t")
    else
      txt = "<no text>"
    end

    typeString = type.to_s
    if (r != nil)
      typeString = r.getVocabulary().getDisplayName(@type)
    end
    return "[@" << getTokenIndex().to_s << "," << @start.to_s << ":" << @stop.to_s << "='" << txt << "',<" << typeString << ">" << channelStr << "," << @line.to_s << ":" << getCharPositionInLine().to_s << "]"
  end

  def to_s()
    return "[@ " << @start.to_s << ":" << @stop.to_s << "," << @line.to_s << ":" << "]"
  end

  def to_s_old()

    channelStr = ""
    if (@channel > 0)
      channelStr = ",channel=" + @channel.to_s
    end
    txt = getText()
    if (txt != nil)
      txt = txt.sub("\n", "\\n")
      txt = txt.sub("\r", "\\r")
      txt = txt.sub("\t", "\\t")
    else
      txt = "<no text>"
    end

    typeString = type.to_s

    return "[@" << getTokenIndex().to_s << "," << @start.to_s << ":" << @stop.to_s << "='" << txt << "',<" << typeString << ">" << channelStr << "," << @line.to_s << ":" << getCharPositionInLine().to_s << "]"
  end

end
