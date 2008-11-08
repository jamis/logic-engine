require 'jamis/logic_engine/database/operation'

module Jamis
  module LogicEngine
    class Database
      class Operation
        class Arithmetic < Operation
          def initialize(db, *parameters)
            super(db, self.class.name.split(/::/).last.downcase.to_sym, *parameters)
          end

          def evaluate(env)
            operands = parameters.map do |parameter|
              value = parameter.dereference(env)
              throw :fail unless value.atom? && value.number?
              value.name
            end

            db.atom(compute(operands))
          end

          def chain(term)
            parameters << (term.is_a?(Term) ? term : db.atom(term))
            self
          end

          def compute(operands)
            raise NotImplementedError, "must be implemented in subclass"
          end
        end
      end
    end
  end
end