require 'jamis/logic_engine/database/term'

module Jamis
  module LogicEngine
    class Database
      class Predicate < Term
        attr_reader :name, :parameters

        def initialize(db, name, *parameters)
          super(db)
          @name = name
          @parameters = parameters.map do |parameter|
            case parameter
            when Term then parameter
            else db.atom(parameter)
            end
          end
        end

        def ==(term)
          Predicate === term &&
          term.name == name &&
          term.parameters == parameters
        end

        def resolve(env, &block)
          trace :enter, :resolve
          db.each do |term|
            trace :iteration, :match, term, self
            env.push do
              result = catch(:fail) { term.cleanup(env).match(self, env) }

              if result
                if result == self || result == term
                  block.call(env)
                else
                  result.resolve(env, &block)
                end
              end

              return if env.cut?
            end
          end
        ensure
          trace :exit, :resolve
        end

        def match(term, env)
          if term.variable?
            term.match(self, env)
          else
            throw :fail unless term.name == name &&
              term.parameters.length == parameters.length
            params = parameters.zip(term.parameters).map { |a,b| b.match(a, env) }
            result = Predicate.new(db, name, *params)
          end
        end

        def cleanup(env, hash={})
          Predicate.new(db, name, *parameters.map { |p| p.cleanup(env, hash) })
        end

        def dereference(env)
          Predicate.new(db, name, *parameters.map { |p| p.dereference(env) })
        end

        def normalize(env={})
          parameters.collect! { |parameter| parameter.normalize(env) }
          self
        end

        def variables
          @variables ||= parameters.map { |param| param.variables }.flatten.uniq
        end

        def predicate?
          true
        end

        def method_missing(sym, *args, &block)
          db.predicate(sym, self, *args, &block)
        end

        def to_s(format=:object)
          return name.to_s if parameters.empty?

          case format
          when :object
            s = parameters.first.to_s
            s << ".#{name}"
            if parameters.length > 1
              s << "("
              s << parameters[1..-1].map { |p| p.to_s }.join(",")
              s << ")"
            end
            s
          when :functional
            s = name.to_s
            if parameters.length > 0
              s << "("
              s << parameters.map { |p| p.to_s(format) }.join(",")
              s << ")"
            end
            s
          else
            raise ArgumentError, "unknown format, #{format}"
          end
        end

        def to_sexp
          [name, *parameters.map { |param| param.to_sexp }]
        end
      end
    end
  end
end