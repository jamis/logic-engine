$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"
require 'jamis/logic_engine/database'

db = Jamis::LogicEngine::Database.new

db.define :write do |me, env|
  me.parameters.each do |parameter|
    print(parameter.dereference(env))
  end
end

db.assert do
  + N.hanoi.if { N.move(left, right, center) }
  + move(0, X, Y, Z).if { cut! }
  + N.move(A, B, C).if {
      M.is(N - 1) &
      M.move(A, C, B) &
      write("move a disc from the ", A, " pole to the ", B, " pole\n") &
      M.move(C, B, A) }
end

puts "hanoi with 2 disks:"
db.query { hanoi(2) }.go!
puts

puts "hanoi with 3 disks:"
db.query { hanoi(3) }.go!
puts

puts "hanoi with 4 disks:"
db.query { hanoi(4) }.go!
puts

puts "hanoi with 5 disks:"
db.query { hanoi(5) }.go!
puts