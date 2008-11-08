require 'jamis/logic_engine/database/function'

module Jamis
  module LogicEngine
    class Database
      class Function
        class Is < Function
          def initialize(db, *parameters)
            super(db, :is, *parameters)
          end

          def resolve(env)
            trace :enter, :resolve

            lhs = parameters.first.dereference(env)
            rhs = parameters.last.dereference(env)
            if lhs.variable? && !env[lhs]
              env.push do
                env[lhs] = rhs.evaluate(env)
                yield env
              end
            end

            trace :exit, :resolve
          end
        end
      end
    end
  end
end