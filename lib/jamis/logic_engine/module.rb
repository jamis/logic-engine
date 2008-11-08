module Jamis
  module LogicEngine
    module Module
      def self.included(where)
        where.send :alias_method, :const_missing_without_logic_engine, :const_missing
        where.send :alias_method, :const_missing, :const_missing_with_logic_engine
      end

      def const_missing_with_logic_engine(sym)
        clean_room = Thread.current[LogicEngine::CleanRoom::TLOCAL_VARNAME]
        if clean_room
          LogicEngine::Database::Variable.new(clean_room.db, sym)
        else
          const_missing_without_logic_engine(sym)
        end
      end
    end
  end
end

class Module
  include Jamis::LogicEngine::Module
end
