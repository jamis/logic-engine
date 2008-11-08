require 'jamis/logic_engine/database/operation/arithmetic'

module Jamis
  module LogicEngine
    class Database
      class Operation
        class Subtraction < Arithmetic
          def compute(operands)
            operands.inject(operands.shift) { |s,v| s - v }
          end

          alias :- :chain
        end
      end
    end
  end
end