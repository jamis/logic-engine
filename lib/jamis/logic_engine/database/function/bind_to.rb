require 'jamis/logic_engine/database/function'

module Jamis
  module LogicEngine
    class Database
      class Function
        class BindTo < Function
          def initialize(db, *parameters)
            super(db, :bind_to, *parameters)
          end

          def resolve(env)
            trace :enter, :resolve

            unless env[parameters.first]
              env.push do
                env[parameters.first] = parameters.last
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