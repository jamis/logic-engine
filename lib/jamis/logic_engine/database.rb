require 'jamis/logic_engine/module'
require 'jamis/logic_engine/clean_room'

require 'jamis/logic_engine/database/atom'
require 'jamis/logic_engine/database/conjunction'
require 'jamis/logic_engine/database/implication'
require 'jamis/logic_engine/database/predicate'
require 'jamis/logic_engine/database/variable'

require 'jamis/logic_engine/database/function/atomic'
require 'jamis/logic_engine/database/function/bind_to'
require 'jamis/logic_engine/database/function/is'
require 'jamis/logic_engine/database/function/not_eq'
require 'jamis/logic_engine/database/function/numeric'
require 'jamis/logic_engine/database/function/proc'

require 'jamis/logic_engine/database/operation/addition'
require 'jamis/logic_engine/database/operation/multiplication'
require 'jamis/logic_engine/database/operation/subtraction'

module Jamis
  module LogicEngine
    class Database
      attr_reader :terms
      attr_reader :atoms

      def initialize(&block)
        @terms = []
        @atoms = Hash.new { |h,k| h[k] = Atom.new(self, k) }
        @variable_number = 0
        @definitions = {}
        assert(&block) if block
      end

      def add(statement)
        statement.normalize
        statement.variables.each { |v| uniqify_variable(v) }
        @terms << statement
      end

      def atom(sym)
        name = case sym
          when Symbol, Numeric then sym
          when String then sym.to_sym
          else raise ArgumentError, "cannot make #{sym.inspect} an atom"
        end

        @atoms[name]
      end

      def assert(&block)
        evaluate(&block)
      end

      def query(limit=nil, &block)
        evaluate(&block).resolver(limit)
      end

      def +(term)
        add(term)
        self
      end

      def each
        @terms.each { |t| yield t }
        self
      end

      def trace(action, method, *args)
        return unless trace?
        args = args.map { |a| a.to_s }.join(", ")
        puts "#{TRACE_PREFIX[action]} #{method} #{args}"
      end

      def trace?
        @trace
      end

      def trace!
        save, @trace = @trace, true
        yield
      ensure
        @trace = save
      end

      def define(name, &block)
        @definitions[name] = block
      end

      def predicate(name, *args)
        if @definitions[name]
          Function::Proc.new(self, name, *args, &@definitions[name])
        else
          Predicate.new(self, name, *args)
        end
      end

      private

        TRACE_PREFIX = {
          :enter     => "==>",
          :exit      => "<==",
          :iteration => "  @",
        }

        def evaluate(&block)
          CleanRoom.new(self, &block)
        end

        def uniqify_variable(var)
          var.name = "#{var.name}__#{@variable_number += 1}"
        end
    end
  end
end