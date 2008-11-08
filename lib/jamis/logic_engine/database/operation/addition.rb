require 'jamis/logic_engine/database/operation/arithmetic'

module Jamis
  module LogicEngine
    class Database
      class Operation
        class Addition < Arithmetic
          def compute(operands)
            operands.inject(0) { |s,v| s + v }
          end

          alias :+ :chain
        end
      end
    end
  end
end