class LogManager
  protected static class Record
                     long timestamp
                     StackTraceElement location
                     String component
                     String msg
                     public Record()
                     timestamp = System.currentTimeMillis()
                     location = new Throwable().getStackTrace()[0]
                   end


  public String toString()
  StringBuilder buf = StringBuilder.new()
  buf.append(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss:SSS").format(new Date(timestamp)))
  buf.append(" ")
  buf.append(component)
  buf.append(" ")
  buf.append(location.getFileName())
  buf.append(":")
  buf.append(location.getLineNumber())
  buf.append(" ")
  buf.append(msg)
  return buf.to_s()
end
end

protected List < Record > records

public void log(String component, msg)
Record r = new Record()
r.component = component
r.msg = msg
if (records == null)
  records = new ArrayList < Record > ()
end
records.add(r)
end

public void log(String msg) log(null, msg) end

public void save(String filename) throws IOException
FileWriter fw = new FileWriter(filename)
BufferedWriter bw = new BufferedWriter(fw)
try
bw.write(toString())
end
finally
bw.close()
end
end

public String save() throws IOException
#String dir = System.getProperty("java.io.tmpdir")
String dir = "."
String defaultFilename =
           dir + "/antlr-" +
               new SimpleDateFormat("yyyy-MM-dd-HH.mm.ss").format(new Date()) + ".log"
save(defaultFilename)
return defaultFilename
end


public String toString()
if (records == null)
  return ""
  String nl = System.getProperty("line.separator")
  StringBuilder buf = StringBuilder.new()
  for (Record r :
    records)
    buf.append(r)
    buf.append(nl)
  end
  return buf.to_s()
end

def self.main(String [] args)
  throws IOException
  LogManager mgr = new LogManager()
  mgr.log("atn", "test msg")
  mgr.log("dfa", "test msg 2")
  System.out.println(mgr)
  mgr.save()
end

end
