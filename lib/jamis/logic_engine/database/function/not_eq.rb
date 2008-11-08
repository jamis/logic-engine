require 'jamis/logic_engine/database/function'

module Jamis
  module LogicEngine
    class Database
      class Function
        class NotEq < Function
          def initialize(db, *parameters)
            super(db, :not_eq, *parameters)
          end

          def resolve(env)
            trace :enter, :resolve

            lhs = parameters.first.dereference(env)
            rhs = parameters.last.dereference(env)
            yield env unless lhs == rhs

            trace :exit, :resolve
          end
        end
      end
    end
  end
end