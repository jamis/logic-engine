$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"

require 'timeout'
require 'test/unit'
require 'jamis/logic_engine/database'

class ResolveTest < Test::Unit::TestCase
  def setup
    @db = Jamis::LogicEngine::Database.new do
      + auckland.by_car_to(hamilton)
      + hamilton.by_car_to(raglan)
      + valmont.by_car_to(metz)
 
      + metz.by_train_to(paris)

      + paris.by_plane_to(los_angeles)
      + los_angeles.by_plane_to(auckland)

      + X.direct_to(Y).if { X.by_car_to(Y) }
      + X.direct_to(Y).if { X.by_train_to(Y) }
      + X.direct_to(Y).if { X.by_plane_to(Y) }

      + X.travel_to(Y).if { X.direct_to(Y) }
      + X.travel_to(Y).if { X.direct_to(Z) & Z.travel_to(Y) }

      + X.direct_to(Y,H).if { X.by_car_to(Y) & H.bind_to(car) }
      + X.direct_to(Y,H).if { X.by_train_to(Y) & H.bind_to(train) }
      + X.direct_to(Y,H).if { X.by_plane_to(Y) & H.bind_to(plane) }
      
      + X.travel_to(Y,P).if { X.direct_to(Y,H) & P.bind_to(H.go(X,Y)) }
      + X.travel_to(Y,P).if { X.direct_to(Z,H) & Z.travel_to(Y,P1) & P.bind_to(H.go(X,Z,P1)) }
      
      + X.is_sibling_of(Y).if { Z.is_mother_of(X) & Z.is_mother_of(Y) & X.not_eq(Y) }
      + judy.is_mother_of(jamis)
      + judy.is_mother_of(nicole)
      + judy.is_mother_of(andrew)
    end
  end

  def test_first_match_with_no_variables
    resolver = @db.query { auckland.by_car_to(hamilton) }
    assert_equal 1, resolver.length
    assert resolver.solutions.first.bindings.empty?
  end

  def test_later_match_with_no_variables
    resolver = @db.query { los_angeles.by_plane_to(auckland) }
    assert_equal 1, resolver.length
    assert resolver.solutions.first.bindings.empty?
  end

  def test_no_match_with_no_variables
    resolver = @db.query { los_angeles.by_car_to(caldwell) }
    assert resolver.empty?
  end

  def test_simple_variable_match
    resolver = @db.query { X.by_train_to(paris) }
    assert_equal 1, resolver.length
    assert_equal "metz", resolver.first[:X].to_s

    resolver = @db.query { metz.by_train_to(X) }
    assert_equal 1, resolver.length
    assert_equal "paris", resolver.first[:X].to_s
  end

  def test_two_way_variable_match
    resolver = @db.query { X.by_plane_to(Y) }
    assert_equal 2, resolver.length
    assert_equal "paris", resolver.first[:X].to_s
    assert_equal "los_angeles", resolver.first[:Y].to_s
    assert_equal "los_angeles", resolver.last[:X].to_s
    assert_equal "auckland", resolver.last[:Y].to_s
  end

  def test_disjunction
    resolver = @db.query { los_angeles.direct_to(auckland) }
    assert_equal 1, resolver.length

    resolver = @db.query { los_angeles.direct_to(paris) }
    assert resolver.empty?
  end

  def test_conjunction
    resolver = @db.query { jamis.is_sibling_of(X) }
    assert_equal 2, resolver.length
    assert_nil resolver.limit
    assert_equal "nicole", resolver.first[:X].to_s
    assert_equal "andrew", resolver.last[:X].to_s
  end

  def test_resolve_with_limit_on_expected_solutions
    resolver = @db.query(1) { jamis.is_sibling_of(X) }
    assert_equal 1, resolver.length
    assert_equal 1, resolver.limit
    assert_equal "nicole", resolver.first[:X].to_s
  end

  def test_recursive
    resolver = @db.query { los_angeles.travel_to(hamilton) }
    assert_equal 1, resolver.length

    resolver = @db.query { los_angeles.travel_to(metz) }
    assert resolver.empty?
  end

  def test_bind_to
    resolver = @db.query { los_angeles.direct_to(auckland,H) }
    assert_equal 1, resolver.length
    assert_equal "plane", resolver.first[:H].to_s
  end

  def test_bind_to_predicate
    resolver = @db.query { los_angeles.travel_to(auckland,H) }
    assert_equal 1, resolver.length
    assert_equal "plane.go(los_angeles,auckland)", resolver.first[:H].to_s
  end

  def test_bind_to_predicate_recursive
    resolver = @db.query { los_angeles.travel_to(hamilton,H) }
    assert_equal 1, resolver.length
    assert_equal "plane.go(los_angeles,auckland,car.go(auckland,hamilton))", resolver.first[:H].to_s
  end

  def test_numeric_is_function
    resolver = number_db.query(1) { is_number(0) }
    assert !resolver.empty?

    resolver = number_db.query(1) { is_number(1) }
    assert !resolver.empty?

    resolver = number_db.query(1) { is_number(2) }
    assert !resolver.empty?

    resolver = number_db.query(1) { is_number(10) }
    assert !resolver.empty?

    resolver = number_db.query(1) { add(4, 5, X) }
    assert_equal 9, resolver.first[:X].name

    resolver = number_db.query(1) { times(4, 5, X) }
    assert_equal 20, resolver.first[:X].name

    resolver = number_db.query(1) { times(4, 5, 6, X) }
    assert_equal 120, resolver.first[:X].name
  end

  def test_cut
    Timeout.timeout(1) do
      resolver = number_db.query { is_number(2) }
      assert_equal 1, resolver.length
    end
  end

  def test_variable_binding_from_within_predicate
    db = Jamis::LogicEngine::Database.new do
      + foo(hello)
      + foo(bar(X)).if { foo(X) }
    end

    resolver = db.query { foo(bar(hello)) }
    assert_equal 1, resolver.length

    resolver = db.query(1) { foo(bar(X)) }
    assert_equal 1, resolver.length
    assert_equal :hello, resolver.first[:X].name

    resolver = db.query(5) { foo(X) }
    assert_equal 5, resolver.length
    assert_equal "hello", resolver[0][:X].to_s
    assert_equal "hello.bar", resolver[1][:X].to_s
    assert_equal "hello.bar.bar", resolver[2][:X].to_s
    assert_equal "hello.bar.bar.bar", resolver[3][:X].to_s
    assert_equal "hello.bar.bar.bar.bar", resolver[4][:X].to_s
  end

  def test_custom_predicate
    db = Jamis::LogicEngine::Database.new

    called_with = nil
    db.define(:testing) do |me, env|
      called_with = me.parameters.first.dereference(env)
      throw :fail if called_with.number? && called_with.name == 13
    end

    db.assert do
      + test_with(0).if { cut! }
      + test_with(X).if { X.testing }
    end

    assert_equal 1, db.query { test_with(0) }.length
    assert_nil   called_with

    assert_equal 1, db.query { test_with(5) }.length
    assert_equal 5, called_with.name

    assert_equal 0, db.query { test_with(13) }.length
    assert_equal 13, called_with.name
  end

  def test_atomic?
    db = Jamis::LogicEngine::Database.new do
      + X.consider(Y).if { X.atomic? & Y.bind_to(atom) & cut! }
      + X.consider(Y).if { Y.bind_to(not_atom) }
    end

    result = db.query { hello.consider(S) }
    assert_equal :atom, result.first[:S].name

    result = db.query { consider(5, S) }
    assert_equal :atom, result.first[:S].name

    result = db.query { bar.foo.consider(S) }
    assert_equal :not_atom, result.first[:S].name

    result = db.query { X.consider(S) }
    assert_equal :not_atom, result.first[:S].name
  end

  def test_numeric?
    db = Jamis::LogicEngine::Database.new do
      + X.consider(Y).if { X.numeric? & Y.bind_to(number) & cut! }
      + X.consider(Y).if { X.atomic? & Y.bind_to(atom) & cut! }
      + X.consider(Y).if { Y.bind_to(other) }
    end

    result = db.query { consider(7, S) }
    assert_equal :number, result.first[:S].name

    result = db.query { foo.consider(S) }
    assert_equal :atom, result.first[:S].name

    result = db.query { bar.foo.consider(S) }
    assert_equal :other, result.first[:S].name
  end

  private

    def number_db
      @number_db ||= Jamis::LogicEngine::Database.new do
        + is_number(0).if { cut! }
        + is_number(N).if { M.is(N - 1) & M.is_number }
        + A.add(B, C).if { A.numeric? & B.numeric? & C.is(A + B) }
        + A.times(B, C).if { A.numeric? & B.numeric? & C.is(A * B) }
        + A.times(B, C, D).if { D.is(A * B * C) }
      end
    end
end
