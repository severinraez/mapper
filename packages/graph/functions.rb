require_package 'fdsl/fdsl'

module Graph
  Functions = FDSL.create do |f|
    # a -> b
    f.json { |obj| obj.to_json }
    # Node -> Hash
    f.to_hash { |node| node.as_json(root: false) }
    # [Node] => [Hash]
    f.many_hash { |nodes| map(to_hash_, nodes) }
    # [Node] -> String
    f.many_json = compose(json_, many_hash_)
  end
end
