require 'jamis/logic_engine/database/predicate'

module Jamis
  module LogicEngine
    class Database
      class Function < Predicate
        def match(term, env)
          raise "undefined"
        end

        def cleanup(env, hash={})
          self.class.new(db, *parameters.map { |p| p.cleanup(env, hash) })
        end

        def dereference(env)
          self.class.new(db, *parameters.map { |p| p.dereference(env) })
        end
      end
    end
  end
end