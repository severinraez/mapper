module FDSL
  Stdlib = FDSL.create do |f|
    # (p, q) -> (a) => p(q(a))
    f.compose { |p, q|
      proc { |*args| p.call(q.call(*args)) } }
    # (a -> b), [a] -> [b]
    f.map { |func, array| array.map(&func) }
  end
end
