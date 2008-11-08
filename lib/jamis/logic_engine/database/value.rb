require 'jamis/logic_engine/database/term'

module Jamis
  module LogicEngine
    class Database
      class Value < Term
        attr_reader :name

        def initialize(db, name)
          super(db)
          @name = name
        end

        def ==(v)
          Value === v && v.name == name
        end

        def method_missing(sym, *args, &block)
          db.predicate(sym, self, *args, &block)
        end

        def to_s(format=:object)
          name.to_s
        end

        def resolve(env)
          raise "undefined"
        end

        def to_sexp
          name
        end
      end
    end
  end
end