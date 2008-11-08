$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"
require 'jamis/logic_engine/database'

def sexp_len(sexp)
  Array === sexp ? sexp.inject(0) { |l,e| l + sexp_len(e) } : 1
end

def simplify(sexp)
  if Array === sexp
    sexp = sexp.map { |exp| simplify(exp) }

    v1 = sexp[1]
    v2 = sexp[2]

    case sexp[0]
    when :plus
      if Numeric === v1 && Numeric === v2 then v1 + v2
      elsif v1 == 0 then v2
      elsif v2 == 0 then v1
      elsif v1 == v2 then [:times, 2, v1]
      else sexp
      end

    when :times
      if Numeric === v1 && Numeric === v2 then v1 * v2
      elsif v1 == 0 || v2 == 0 then 0
      elsif v1 == 1 then v2
      elsif v2 == 1 then v1
      elsif v1 == -1 then [:uminus, v2]
      elsif v2 == -1 then [:uminus, v1]
      elsif v1 == v2 then [:pow, v1, 2]
      else sexp
      end

    when :pow
      if Numeric === v1 && Numeric === v2 then v1 ** v2
      elsif v1 == 0 then  0
      elsif v1 == 1 || v2 == 0 then 1
      elsif v2 == 1 then v1
      else sexp
      end

    else
      sexp
    end
  else
    sexp
  end
end

# Adapted from Mauricio Fernandez' excellent article on logic programming
# in Ruby: http://eigenclass.org/hiki.rb?tiny+prolog+in+ruby

DB = Jamis::LogicEngine::Database.new do
  + X.diff(X, 1).if { cut! }
  + Y.diff(X, 0).if { Y.atomic? & Y.not_eq(X) }
  + A.plus(B).diff(X, DA.plus(DB)).if { A.diff(X, DA) & B.diff(X, DB) }
  + C.times(U).diff(X, C.times(DU)).if { C.atomic? & C.not_eq(X) & U.diff(X, DU) & cut! }
  + A.times(B).diff(X, A.times(DB).plus(DA.times(B))).if { A.diff(X, DA) & B.diff(X, DB) }
  + Y.uminus.diff(X, DY.uminus).if { Y.diff(X, DY) }
  + U.minus(V).diff(X, DU.minus(DV)).if { U.diff(X, DU) & V.diff(X, DV) }
  + U.div(V).diff(X, W).if { U.times(V.pow(-1)).diff(X, W) }
  + Y.pow(C).diff(X, C.times(W.times(Y.pow(E)))).if { C.atomic? & C.not_eq(X) & E.is(C - 1) & Y.diff(X, W) }
  + Y.ln.diff(X, W.times(Y.pow(-1))).if { Y.diff(X, W) }
  + U.exp.diff(X, DU.times(U.exp)).if { U.diff(X, DU) }
  + V.pow(W).diff(X, Z).if { W.times(V.ln).exp.diff(X, Z) }
end

def diff(variable, &query)
  result = DB.query(&query)
  puts result.goal.to_s(:functional)

  best_length = 1_000_000
  best = nil

  result.each do |solution|
    answer = solution[variable]
    sexp = simplify(answer.to_sexp)
    length = sexp_len(sexp)

    if length < best_length
      best_length = length
      best = [answer.to_s(:functional), sexp]
    end
  end

  if best
    puts "  > raw solution: #{best.first}"
    puts "    simplified  : #{best.last.inspect}"
  else
    puts "no solution could be found"
  end
end

diff(:S) { x.pow(2).plus(times(3,x)).diff(x, S) }
puts
diff(:S) { x.pow(5).div(z.plus(x)).diff(x, S) }