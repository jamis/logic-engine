require 'jamis/logic_engine/database/value'

module Jamis
  module LogicEngine
    class Database
      class Atom < Value
        def match(term, env)
          return term.match(self, env) unless term.atom?
          throw :fail unless self == term
          self
        end

        def atom?
          true
        end

        def number?
          Numeric === name
        end
      end
    end
  end
end