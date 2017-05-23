class FDSL

  def self.create(&dsl_block)
    container = Module.new do
      extend MethodShortcut
    end

    modifier = ModuleModifier.new(container)
    container.instance_exec(modifier, &dsl_block)

    container
  end

  module MethodShortcut
    def method_missing(name, *args, &block)
      string_name = name.to_s
      if string_name.end_with?('_')
        method(string_name[0..-2].to_sym)
      else
        super(name, *args, &block)
      end
    end
  end

  class ModuleModifier
    def initialize(target)
      @target = target
    end

    def method_missing(name, *args, &block)
      if name.to_s.end_with?('=')
        body_proc = args.first
        method_name = name.to_s[0..-2].to_sym
        add_function(method_name, &body_proc)
      else
        add_function(name, &block)
      end
    end

    private
    def add_function(function_name, &function_body)
      target.singleton_class.class_eval do
        define_method(function_name, &function_body)
      end
    end

    attr_reader :target
  end

end
