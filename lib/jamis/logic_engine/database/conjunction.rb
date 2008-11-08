require 'jamis/logic_engine/database/predicate'

module Jamis
  module LogicEngine
    class Database
      class Conjunction < Predicate
        def initialize(db, *parameters)
          super(db, :and, *parameters)
        end

        def &(term)
          parameters << term
          self
        end

        def match(term, env)
          raise "undefined"
        end

        def cleanup(env, hash={})
          Conjunction.new(db, *parameters.map { |p| p.cleanup(env, hash) })
        end

        def dereference(env)
          Conjunction.new(db, *parameters.map { |p| p.dereference(env) })
        end

        def resolve(env, &block)
          trace :enter, :resolve
          list = parameters

          resolver = Proc.new do
            if list.empty?
              block.call(env)
            else
              term = list.first.dereference(env)
              old_list, list = list, list[1..-1]
              begin
                term.resolve(env, &resolver)
              ensure
                list = old_list
              end
            end
          end 

          env.push { resolver.call }
          trace :exit, :resolve
        end

        def to_s
          parameters.map { |p| p.to_s }.join(" & ")
        end
      end
    end
  end
end