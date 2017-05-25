class FDSL

  def self.create(&dsl_block)
    methods = Module.new do
    end

    container = Module.new do
      extend MethodShortcut

      class << self
        attr_accessor :_methods
      end
    end
    container._methods = methods

    modifier = ModuleModifier.new(container)
    container.instance_exec(modifier, &dsl_block)

    container._methods = methods

    container
  end

  # Execute a block with libraries of given functions exposed as methods on scope.
  #
  # @param libs Array list of libraries, first will take precedence
  def self.with_libs(*libs, &block)
    context = Module.new do
      libs.reverse.each do |lib|
        extend lib._methods
      end

      class << self
        attr_accessor :_parent_binding
      end

      def self.method_missing(method, *args, &block)
        _parent_binding.send(method, *args, &block)
      end
    end

    context._parent_binding = eval("self", block.binding)
    context.instance_exec(&block)
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
      target._methods.instance_eval do
        define_method(function_name, &function_body)
      end
      target.instance_eval do
        extend _methods
      end
    end

    attr_reader :target
  end

end
