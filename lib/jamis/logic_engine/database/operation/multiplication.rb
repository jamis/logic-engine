require 'jamis/logic_engine/database/operation/arithmetic'

module Jamis
  module LogicEngine
    class Database
      class Operation
        class Multiplication < Arithmetic
          def compute(operands)
            operands.inject(1) { |p,v| p * v }
          end

          alias :* :chain
        end
      end
    end
  end
end