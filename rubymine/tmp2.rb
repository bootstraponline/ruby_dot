root_parent, root_hash, root_name = [1, 1, "A"]
@root_name = root_name

# parent_hash, node_hash, node_name
names                               = [
    [1, 1, 'A'],
    [1, 2, 'B'],
    [2, 3, 'C'],
    [3, 7, 'G'],

    [2, 4, 'D'],
    [1, 5, 'E'],
    [5, 6, 'F']
]

=begin

A::B::C::G
A::B::D
A::E::F

=end

puts "Raw data:"
puts names.inspect

hash_to_name = {}

names.each do |_, node_hash, name|
  hash_to_name[node_hash] = name
end

puts '---'
puts "Node hash to name:"
puts hash_to_name
puts '---'

node_hierarchy = {}
names.each do |element|
  ele_parent, ele_hash, ele_name = *element
  next if ele_hash == root_hash

  parent_name                           = hash_to_name[ele_parent]
  node_hierarchy[parent_name]           ||= {}
  node_hierarchy[parent_name][ele_name] ||= []
end

puts '---'
puts "Node hierarchy"
puts node_hierarchy
puts '----'


node_hierarchy.dup.each do |element, children|
  children.dup.each do |child_name, child_children|
    if node_hierarchy[child_name]
      node_hierarchy[element][child_name] = node_hierarchy[child_name]
    end
  end
end

node_hierarchy.keys.each { |key| node_hierarchy.delete key unless key == root_name }

puts "Node hierarchy"
puts node_hierarchy
puts '----'

# Node hierarchy
# {"A"=>{"B"=>{"C"=>{"G"=>[]}, "D"=>[]}, "E"=>{"F"=>[]}}}

# @keys = []
# def inspect_hash(parent, hash)
#   @last_parent = parent
#   hash.each do |key, value|
#     if value.is_a?(Hash)
#       @keys << key
#       inspect_hash(key, value)
#     else
#       @keys << parent if @last_parent != @keys.last
#       @keys << key
#       puts "#{@keys.join '::'}"
#       @keys = [@root_name]
#     end
#   end
# end


def inspect_hash(path, hash)
  hash.each do |key, value|
    if value.is_a?(Hash)
      inspect_hash(path + [key], value)
    else
      puts "#{(path + [key]).join '::'}"
    end
  end
end

inspect_hash [], node_hierarchy

# Goal:
# A::B::C::G
# A::B::D
# A::E::F

# Current status:
# A::B::C::G
# A::B::D
# A::E::F

# Is this the optimal solution?
