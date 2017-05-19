class FDSL
  # SYNTAX

  # To define an anonymous function: f{ |arg| arg + 1 }
  def func(&block)
    raise 'Need a block' unless block_given?

    BlockAsLambda.new(binding, &block).lambda
  end

  # HELPERS

  def initialize
    @proc_store = {}
  end

  # To define a named function: FDSL#function_name { |arg| arg + 1 }
  def method_missing(name, *method_args, &block)
    raise NoMethodError.new("Function #{name} not defined in this dsl") unless block_given?

    # Define a new method that returns a lambda that will
    # evaluate the block given with access to the methods and syntax
    # of this FDSL instance.

    l = BlockAsLambda.new(binding, &block).lambda
    method_name = name

    # For definitions such as
    #
    #     f.many_json! {  compose[json, many_hash] }
    #
    # Evaluate the lambda right away and use the resulting function
    if name.to_s[-1] == '!'
      unless method_args.empty?
        raise "Defining method #{name} by execution of a block; expected no arguments, got #{arguments}"
      end

      l = instance_exec(&l)

      unless l.is_a?(Proc)
        raise "Defining method #{name} by execution of a block; expected the block to use f{...} to define a function, got a #{l.class.name}"
      end

      method_name = name.to_s.chomp('!')
    end

    # Define Proc that executes the lambda in this class' context.
    proc = -> (*args) {
      val = instance_exec(*args, &l)
      val
    }

    # Add getter method for the proc.
    metaclass.send :define_method, method_name do |*args|
      proc
    end
  end

  class BlockAsLambda
    def initialize(parent_binding, &block)
      @parent_binding = parent_binding

      # Define a helper method. Convert it via to_proc,
      # thus converting our block to a lambda with validated argument lists.
      metaclass.send :define_method, :_lambda, &block
      @lambda = method(:_lambda).to_proc
    end

    def method_missing(name, *args, &block)
      method = @parent_binding.eval("method(#{name.inspect})")
      method.call(*args, &block)
    end

    attr_reader :lambda

    private
    def metaclass
      class << self; self; end
    end
  end

  def metaclass
    class << self; self; end
  end
end
