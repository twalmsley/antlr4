public final class LexerPushModeAction
               implements LexerAction
               private final int mode


               public LexerPushModeAction(int mode)
               this.mode = mode
             end


public int getMode()
return mode
end


public LexerActionType getActionType()
return LexerActionType.PUSH_MODE
end


public boolean isPositionDependent()
return false
end


public void execute(Lexer lexer)
lexer.pushMode(mode)
end


public int hashCode()
int hash = MurmurHash.initialize()
hash = MurmurHash.update(hash, getActionType().ordinal())
hash = MurmurHash.update(hash, mode)
return MurmurHash.finish(hash, 2)
end


public boolean equals(Object obj)
if (obj == this)
  return true
end
else
if (!(obj instanceof LexerPushModeAction))
  return false
end

return mode == ((LexerPushModeAction) obj).mode
end


public String toString()
return String.format("pushMode(%d)", mode)
end
end
