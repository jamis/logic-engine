require 'jamis/logic_engine/environment'

module Jamis
  module LogicEngine
    class Resolver
      include Enumerable

      attr_reader :goal, :limit

      def initialize(goal, limit=nil)
        raise ArgumentError, "no goal specified to resolve" unless goal
        @goal = goal
        @limit = limit
      end

      %w(empty? length first last).each do |name|
        class_eval "def #{name}; solutions.#{name}; end"
      end

      def [](index)
        solutions[index]
      end

      def each
        if @solutions
          @solutions.each { |s| yield s }
        else
          @solutions = []
          env = Environment.new(@goal.db, @goal.variables)
          @goal.resolve(env) do |s|
            s = s.capture
            @solutions << s
            yield s if block_given?
            break if @limit && @solutions.length >= @limit
          end
        end
        self
      end

      def solutions
        find_all_solutions!
        instance_eval "def solutions; @solutions; end"
        @solutions
      end

      def go!
        find_all_solutions!
        self
      end

      private

        def find_all_solutions!
          return if @solutions
          each
        end
    end
  end
end