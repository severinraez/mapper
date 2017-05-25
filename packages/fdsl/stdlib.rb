module FDSL
  Stdlib = FDSL.create do |f|
    # (p, q) -> (a) => p(q(a))
    f.compose { |p, q|
      proc { |*args| p.call(q.call(*args)) } }
    # (a -> b), [a] -> [b]
    f.map { |func, array| array.map(&func) }

    f.typed { |type_to_procs|
      proc { |*args|
        type = args.first.class

        delegate = type_to_procs[type] || type_to_procs.fetch(:default)
        delegate.call(*args)
      }
    }

    # [proc, ...] => proc
    f.curry { |bound_proc, *bound_args|
      proc { |*args| bound_proc.call(bound_args + args) }
    }

    # [proc, v, [list]] => w
    f.reduce { |func, initial, list|
      if list.length == 0
        initial
      else
        value = func.call(initial, list[0])
        reduce(func, value, list[1..-1])
      end
    }
  end
end
