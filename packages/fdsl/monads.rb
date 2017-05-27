module FDSL
  class Maybe
  end

  class Just < Maybe
  end

  class Nothing < Maybe
  end

  Monads = FDSL.create do |f|
    f.maybe_arrow { |*funcs|
      build_nothing_forwarder = proc { |func|
        typed(:else => func,
              Nothing => proc { |nothing| nothing }) }
      arrow(map(build_nothing_forwarder, funcs)) }
  end
end



