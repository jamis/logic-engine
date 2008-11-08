require 'jamis/logic_engine/database/function'

module Jamis
  module LogicEngine
    class Database
      class Function
        class Proc < Function
          def initialize(db, name, *parameters, &callback)
            super(db, name, *parameters)
            raise ArgumentError, "no callback given for #{name}" unless callback
            @callback = callback
          end

          def resolve(env)
            trace :enter, :resolve
            yield env if catch(:fail) { @callback[self, env]; true }
          ensure
            trace :exit, :resolve
          end

          def cleanup(env, hash={})
            self.class.new(db, name, *parameters.map { |p| p.cleanup(env, hash) }, &@callback)
          end

          def dereference(env)
            self.class.new(db, name, *parameters.map { |p| p.dereference(env) }, &@callback)
          end
        end
      end
    end
  end
end