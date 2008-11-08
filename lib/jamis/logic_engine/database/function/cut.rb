require 'jamis/logic_engine/database/function'

module Jamis
  module LogicEngine
    class Database
      class Function
        class Cut < Function
          def initialize(db)
            super(db, :cut!)
          end

          def resolve(env)
            trace :enter, :resolve
            yield env
            env.cut!
            trace :exit, :resolve
          end
        end
      end
    end
  end
end