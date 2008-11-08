$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"

require 'test/unit'
require 'jamis/logic_engine/database'

class DslTest < Test::Unit::TestCase
  DB = Jamis::LogicEngine::Database

  def test_method_missing_creates_atoms
    db = DB.new do
      hello
      world
    end

    assert db.atoms.key?(:hello)
    assert db.atoms.key?(:world)
  end

  def test_string_parameters_create_atoms
    db = DB.new { + testing.with_something("foo", "bar") }
    assert db.atoms.key?(:foo)
    assert db.atoms.key?(:bar)
  end

  def test_symbol_parameters_create_atoms
    db = DB.new { + testing.with_something(:foo, :bar) }
    assert db.atoms.key?(:foo)
    assert db.atoms.key?(:bar)
  end

  def test_predicate_without_receiver
    db = DB.new { + do_something(:foo) }

    assert_equal 1, db.terms.length
    assert_instance_of DB::Predicate, db.terms.first
    assert_equal 1, db.terms.first.parameters.length
    assert_equal :foo, db.terms.first.parameters.first.name
  end

  def test_numeric_atoms
    db = DB.new { + is_number(17) }
    assert_equal 17, db.terms.first.parameters.first.name
  end

  def test_dsl_with_custom_predicate
    db = DB.new
    db.define(:testing) { |me, env| }
    db.assert { + X.testing; + testing(Y) }
    assert_equal 2, db.terms.length
    assert_instance_of DB::Function::Proc, db.terms.first
    assert_instance_of DB::Function::Proc, db.terms.last
    assert_equal :testing, db.terms.first.name
    assert_equal :testing, db.terms.last.name
  end
end