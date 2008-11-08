$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"
require 'jamis/logic_engine/database'

db = Jamis::LogicEngine::Database.new do
  + add(0,Y,Y)
  + add(succ(X),Y,succ(Z)).if { add(X,Y,Z) }
end

result = db.query(1) { add(succ(succ(0)), succ(succ(0)), S) }
puts "solving `#{result.goal.to_s(:functional)}' for S:"

if result.empty?
  puts "no solution found"
else
  puts result.first[:S].to_s(:functional)
end
