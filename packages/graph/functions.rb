require_package 'fdsl/fdsl'

module Graph
  Functions = f = FDSL.new
  fi = f # Impure functions

  # As a dsl reminder on how to return a function:
  # f.many_json { |nodes| f{ map[json, nodes] } }

  # (p, q) -> (a) => p(q(a))
  f.compose { |p, q| func { |*args| p[q[*args]] } }
  # a -> b
  f.json { |obj| obj.to_json }
  # (a -> b), [a] -> [b]
  f.map { |func, array| array.map(&func) }

  # Node -> Hash
  f.to_hash { |node| node.as_json(root: false) }
  # [Node] => [Hash]
  f.many_hash { |nodes| map[to_hash, nodes] }
  # [Node] -> String
  f.many_json! { compose[json, many_hash] }
end
