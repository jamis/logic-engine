require 'jamis/logic_engine/database/value'

module Jamis
  module LogicEngine
    class Database
      class Variable < Value
        def name=(v)
          @name = v.to_sym
        end

        def variables
          [self]
        end

        def match(term, env)
          if Variable === term
            if !env[name] && !env[term.name]
              var = env.intermediate_variable
              env[name] = env[term.name] = var
            elsif env[name] && !env[term.name]
              env[term.name] = self
            elsif env[term.name] && !env[name]
              env[name] = term
            elsif env[term.name] != env[name]
              throw :fail
            else
              env[name]
            end
          elsif env[name] && env[name] != term
            throw :fail
          else
            env[name] = term
          end
        end

        def cleanup(env, hash={})
          hash[name] ||= env[self] || env.intermediate_variable
        end

        def dereference(env)
          result = env.dereference(self)
          Variable === result ? result : result.dereference(env)
        end

        def normalize(env={})
          env[name] ||= self
        end

        def bind_to(term)
          Function::BindTo.new(db, self, term)
        end

        def not_eq(term)
          Function::NotEq.new(db, self, term)
        end

        def atomic?
          Function::Atomic.new(db, self)
        end

        def numeric?
          Function::Numeric.new(db, self)
        end

        def is(term)
          Function::Is.new(db, self, term)
        end

        def -(term)
          Operation::Subtraction.new(db, self, term)
        end

        def +(term)
          Operation::Addition.new(db, self, term)
        end

        def *(term)
          Operation::Multiplication.new(db, self, term)
        end

        def variable?
          true
        end
      end
    end
  end
end