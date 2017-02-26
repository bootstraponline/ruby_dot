module A
  module B
    module C
    end
  end
end

module E
end

module F
end

module G
end

module H::I::J
end


=begin

::left::
s(:const, nil, :A)

::right (children)::
s(:module,
  s(:const, nil, :B),
  s(:module,
    s(:const, nil, :C), nil))

::node::
s(:module,
  s(:const, nil, :A), -- left
  s(:module,
    s(:const, nil, :B),
    s(:module,
      s(:const, nil, :C), nil)))


---- second node ----

 s(:module,
  s(:const, nil, :B),
  s(:module,
    s(:const, nil, :C), nil))

-----

node.type = :module || :const
node.has = have we seen this node before

=end