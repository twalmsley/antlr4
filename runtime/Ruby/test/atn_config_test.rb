require '../antlr4/ATNConfig'

cfg = ATNConfig.new

depth = cfg.getOuterContextDepth

puts "depth is not a number" if !depth.is_a? Fixnum
puts depth if depth >0
puts depth if depth <=0

