$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"
require 'jamis/logic_engine/database'

db = Jamis::LogicEngine::Database.new do
  + X.is_sibling_of(Y).if { Z.is_parent_of(X) & Z.is_parent_of(Y) & X.not_eq(Y) }
  + X.is_parent_of(Y).if { X.is_father_of(Y) }
  + X.is_parent_of(Y).if { X.is_mother_of(Y) }
end

db.assert do
  %w(rj arin tarasine lauren garret nick marc corrine clarke).each do |name|
    + ronald.is_father_of(name)
  end
end

result = db.query { tarasine.is_sibling_of(X) }
puts "#{result.goal}, where X is:"
result.each do |solution|
 puts " - #{solution.bindings[:X]}"
end
puts "no solutions!" if result.empty?
