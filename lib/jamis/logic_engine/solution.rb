module Jamis
  module LogicEngine
    class Solution
      attr_reader :bindings

      def initialize(env)
        @bindings = env.variables.inject({}) do |h,v|
          h[v.name] = v.dereference(env)
          h
        end
      end

      def [](name)
        bindings[name]
      end
    end
  end
end