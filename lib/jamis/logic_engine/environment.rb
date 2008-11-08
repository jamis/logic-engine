require 'jamis/logic_engine/solution'
require 'jamis/logic_engine/database/variable'

module Jamis
  module LogicEngine
    class Environment
      class Frame
        def initialize(previous=nil)
          @previous = previous
          @bindings = {}
          @cut = false
        end

        def cut!
          @cut = true
        end

        def cut?
          @cut
        end

        def keys
          (@bindings.keys + (@previous ? @previous.keys : [])).uniq
        end

        def [](name)
          return @bindings[name] if @bindings.key?(name)
          @previous[name] if @previous
        end

        def []=(name, value)
          @bindings[name] = value
        end

        def push
          Frame.new(self)
        end

        def pop
          head, @previous = @previous, nil
          head
        end
      end

      attr_reader :db, :frames, :variables

      def initialize(db, variables)
        @db = db
        @variables = variables
        @frames = Frame.new
        @next_var_num = 0
      end

      def intermediate_variable
        Database::Variable.new(db, next_temp_var_name)
      end

      def next_temp_var_name
        :"Temp__#{@next_var_num += 1}"
      end

      def [](name)
        name = name.name if name.respond_to?(:name)
        @frames[name]
      end

      def []=(name, value)
        name = name.name if name.respond_to?(:name)
        @frames[name] = value
      end

      def keys
        @frames.keys
      end

      def push
        @frames = @frames.push
        if block_given?
          begin
            yield
          ensure
            pop
          end
        end
      end

      def pop
        @frames = @frames.pop
        self
      end

      def cut!
        @frames.cut!
      end

      def cut?
        @frames.cut?
      end

      def dereference(var)
        return var unless Database::Variable === var
        loop do
          v = self[var]
          return var unless v
          var = v
          return var unless Database::Variable === var
        end
      end

      def capture
        Solution.new(self)
      end
    end
  end
end