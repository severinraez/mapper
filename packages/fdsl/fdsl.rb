class FDSL
  # DATA TYPES

  # A side effects free function.
  class Function < Proc
  end

  # A function with side effects.
  class ImpureFunction < Function; end

  # SYNTAX

  # To define an anonymous function : f{ |arg| arg + 1 }
  def f(&block)
    puts 'f called'
    Function.new(&block)
  end

  def f!(&block)
    ImpureFunction.new(&block)
  end

  # HELPERS

  def initialize
    @proc_store = {}
  end

  # To define a named function: FDSL#function_name { |arg| arg + 1 }
  def method_missing(name, *method_args, &block)
    # Define a new method that returns a lambda that will
    # evaluate the block given with access to the methods and syntax
    # of this FDSL instance.

    private_name = "_#{name}"

    # Define a helper method. This, when converted via to_proc,
    # will generate a lambda, thus we have validated argument lists.
    metaclass.send :define_method, private_name do |*args|
      val = instance_exec(*args, &block)
      val
    end

    metaclass.send :define_method, name do |*args|
      @proc_store[name] ||= method(private_name).to_proc
    end
  end

  def metaclass
    class << self; self; end
  end
end
