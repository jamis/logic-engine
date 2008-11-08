$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"

require 'test/unit'
require 'jamis/logic_engine/database'

class SexpTest < Test::Unit::TestCase
  DB = Jamis::LogicEngine::Database

  def setup
    @db = DB.new
  end

  def test_atom_as_sexp_is_symbol
    atom = @db.atom(:hello)
    assert_equal :hello, atom.to_sexp
  end

  def test_numeric_atom_as_sexp_is_number
    atom = @db.atom(14)
    assert_equal 14, atom.to_sexp
  end

  def test_variable_as_sexp_is_symbol
    var = DB::Variable.new(@db, :X)
    assert_equal :X, var.to_sexp
  end

  def test_predicate_as_sexp_is_array
    predicate = @db.predicate(:hello, :world, 7)
    assert_equal [:hello, :world, 7], predicate.to_sexp
  end

  def test_term_as_sexp_is_recursive
    predicate = @db.predicate(:one, :two, @db.predicate(:three, :four, 5),
      @db.predicate(:six, @db.predicate(:seven, :eight)), 9)
    assert_equal [:one, :two, [:three, :four, 5], [:six, [:seven, :eight]], 9],
      predicate.to_sexp
  end
end