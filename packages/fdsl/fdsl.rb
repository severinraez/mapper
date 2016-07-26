class FDSL
  # DATA TYPES

  # Side effects free function
  class Function < Proc
  end

  # Function with side effects
  class ImpureFunction < Function; end

  # SYNTAX

  def f(&block)
    puts 'f called'
    Function.new(&block)
  end

  def f!(&block)
    ImpureFunction.new(&block)
  end

  def run(&block)
  end

  # HELPERS
  def method_missing(name, *method_args, &block)
    metaclass.send :define_method, name do |*args|
      val = instance_exec(*args, &block)
      val
    end

    metaclass.send :define_method, :"_#{name}" do |*args|
      raise "_#{name}: No arguments expected for a reference, got #{args.inspect}" unless args.empty?
      method(name)
    end
  end

  def metaclass
    class << self; self; end
  end
end
