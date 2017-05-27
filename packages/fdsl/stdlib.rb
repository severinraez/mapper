module FDSL
  Stdlib = FDSL.create do |f|
    # Reverse compose. Naming taken from haskell.
    # (p, q) -> (a) => p(q(a))
    # (p, q, ... z) -> (a) => z(q(...p(a)))
    f.arrow { |*funcs|
      proc { |arg|
        apply = proc{ |arg_or_result, func| func.call(arg_or_result) }
        reduce(apply, arg, funcs) } }

    # (p, q) -> (a) => q(p(a))
    # (p, q, ... z) -> (a) => p(q(...z(a)))
    f.compose { |*funcs|
      arrow(*funcs.reverse)
    }

    # (a -> b), [a] -> [b]
    f.map { |func, array| array.map(&func) }

    f.typed { |type_to_procs|
      hashed = _typed_rehash_hierarchical(type_to_procs)
      proc { |*args|
        delegate = _typed_dig_type_hash(args, hashed)
        if delegate.nil?
          raise ArgumentError.new("Could not map arguments to any of the given types #{type_to_procs.keys.inspect}")
        end

        delegate.call(*args)
      }
    }

    # ({[a, b, c] => proc}) -> [{a => {b => {c => proc}}}]
    f._typed_rehash_hierarchical { |type_to_procs|
      arrayified_type_to_procs = Hash[type_to_procs.map{ |k, v| [Array(k), v] }]
      types_by_desc_length = arrayified_type_to_procs.keys.
                             sort_by{ |k| -k.length }

      types_by_desc_length.each_with_object({}) do |types, result|
        target = result
        types[0..-2].each do |type|
          target[type] ||= {}
          target = target[type]
        end

        delegate = arrayified_type_to_procs[types]

        if target.key?(types.last)
          target[types.last][:else] = delegate
        else
          target[types.last] = delegate
        end
      end
    }

    f._typed_dig_type_hash { |args, hashed|
      arg = args.first

      matching_type = hashed.keys.reject{ |k| k == :else }.find{ |type| arg.is_a?(type) }
      match = hashed[matching_type || :else]

      if match.nil?
        nil
      elsif match.is_a? Proc
        match
      elsif args.length == 1
        nil # We cannot dig deeper.
      else
        _typed_dig_type_hash(args[1..-1], match)
      end
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
