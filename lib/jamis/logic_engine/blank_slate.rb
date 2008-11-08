module Jamis
  module LogicEngine
    class BlankSlate
      KEEPER_METHODS = %w(__id__ __send__ inspect class instance_eval hash)
      (instance_methods - KEEPER_METHODS).each do |v|
        next if v[-1] == ?? || v[-1] == ?!
        undef_method(v)
      end
    end
  end
end