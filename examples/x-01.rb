$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"
require 'jamis/logic_engine/database'

db = Jamis::LogicEngine::Database.new do
 + X.is_sibling_of(Y).if { Z.is_parent_of(X) & Z.is_parent_of(Y) & X.not_eq(Y) }
 + X.is_parent_of(Y).if { X.is_father_of(Y) }
 + X.is_parent_of(Y).if { X.is_mother_of(Y) }
end

db.assert do
 + tarasine.is_mother_of(kaitrin)
 + tarasine.is_mother_of(nathaniel)
end

def show_result_of_query(db, &block)
  result = db.query(&block)

  puts "query: #{result.goal}"
  if result.empty?
    puts "  sorry, #{result.length} solutions found"
  else
    result.each_with_index do |solution, index|
      puts "  ##{index+1}:"
      solution.bindings.each do |v, val|
        puts "  - #{v}: #{val}"
      end
    end
  end
end

show_result_of_query(db) { tarasine.is_mother_of(kaitrin) }
show_result_of_query(db) { tarasine.is_mother_of(X) }
show_result_of_query(db) { X.is_mother_of(kaitrin) }
show_result_of_query(db) { X.is_mother_of(Y) }
show_result_of_query(db) { tarasine.is_parent_of(X) }
show_result_of_query(db) { nathaniel.is_sibling_of(X) }
show_result_of_query(db) { X.is_sibling_of(Y) }
show_result_of_query(db) { nathaniel.is_sibling_of(tarasine) }
show_result_of_query(db) { nathaniel.is_sibling_of(nathaniel) }
