require 'jamis/logic_engine/database/predicate'

module Jamis
  module LogicEngine
    class Database
      class Implication < Predicate
        def initialize(db, *parameters)
          super(db, :implies, *parameters)
        end

        def lhs
          parameters.first
        end

        def rhs
          parameters.last
        end

        def cleanup(env, hash={})
          Implication.new(db, *parameters.map { |p| p.cleanup(env, hash) })
        end

        def dereference(env)
          Implication.new(db, *parameters.map { |p| p.dereference(env) })
        end

        def resolve(env)
          raise "undefined"
        end

        def match(term, env)
          if lhs.match(term, env)
            rhs.dereference(env)
          end
        end

        def to_s
          "#{lhs}.if { #{rhs} }"
        end
      end
    end
  end
end