require 'jamis/logic_engine/resolver'
require 'jamis/logic_engine/database/predicate'
require 'jamis/logic_engine/database/function/cut'

module Jamis
  module LogicEngine
    class CleanRoom < BlankSlate
      TLOCAL_VARNAME = :kbase_database_cleanroom

      attr_reader :db

      def initialize(db, &block)
        @db = db
        @statement = instance_eval(&block) if block
      end

      def resolver(limit=nil)
        Resolver.new(@statement, limit)
      end

      def instance_eval(*args, &block)
        old, Thread.current[TLOCAL_VARNAME] = Thread.current[TLOCAL_VARNAME], self
        super
      ensure
        Thread.current[TLOCAL_VARNAME] = old
      end

      def method_missing(sym, *args)
        if args.empty? && !block_given?
          case sym
          when :cut!
            Database::Function::Cut.new(db)
          else
            db.atom(sym)
          end
        elsif !block_given?
          db.predicate(sym, *args)
        else
          super
        end
      end
    end
  end
end