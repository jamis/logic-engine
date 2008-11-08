$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"
require 'jamis/logic_engine/database'

db = Jamis::LogicEngine::Database.new do
  + auckland.by_car_to(hamilton)
  + hamilton.by_car_to(raglan)
  + valmont.by_car_to(saarbruecken)
  + valmont.by_car_to(metz)
 
  + metz.by_train_to(frankfurt)
  + saarbruecken.by_train_to(frankfurt)
  + metz.by_train_to(paris)
  + saarbruecken.by_train_to(paris)

  + frankfurt.by_plane_to(bangkok)
  + frankfurt.by_plane_to(singapore)
  + paris.by_plane_to(los_angeles)
  + bangkok.by_plane_to(auckland)
  + los_angeles.by_plane_to(auckland)

  + X.direct_to(Y,H).if { X.by_car_to(Y) & H.bind_to(car) }
  + X.direct_to(Y,H).if { X.by_train_to(Y) & H.bind_to(train) }
  + X.direct_to(Y,H).if { X.by_plane_to(Y) & H.bind_to(plane) }

  + X.travel_to(Y,P).if { X.direct_to(Y,H) & P.bind_to(H.go(X,Y)) }
  + X.travel_to(Y,P).if { X.direct_to(Z,H) & Z.travel_to(Y,P1) & P.bind_to(H.go(X,Z,P1)) }
end

result = db.query { valmont.travel_to(raglan,P) }
puts "solving `#{result.goal}' for P:"

if result.empty?
  puts "no solution found"
else
  puts "#{result.length} solutions found:"
  result.each do |solution|
    path = solution[:P]
    # format the output nicely
    puts path.to_s.gsub(/,(\w+\.go)/, ",\n  \\1")
    puts
  end
end
