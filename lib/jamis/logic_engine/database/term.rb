require 'jamis/logic_engine/blank_slate'

module Jamis
  module LogicEngine
    class Database
      class Term < BlankSlate
        attr_reader :db

        def initialize(db)
          @db = db
        end

        def +@
          db.add(self)
        end

        def &(term)
          Conjunction.new(db, self, term)
        end

        def if
          Implication.new(db, self, yield)
        end

        def normalize(env={})
          self
        end

        def cleanup(env, hash={})
          self
        end

        def dereference(env)
          self
        end

        def variables
          []
        end

        def variable?
          false
        end

        def atom?
          false
        end

        def predicate?
          false
        end

        def to_sexp
          raise NotImplementedError, "don't know how to convert #{self.class} to a sexp"
        end

        private

          def trace(action, method, *args)
            return unless db.trace?
            args << self if args.empty?
            db.trace(action, method, *args)
          end
      end
    end
  end
end