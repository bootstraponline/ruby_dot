module RubyDot
  # Collect fully qualified class & module names
  #
  # https://github.com/whitequark/parser/blob/master/lib/parser/ast/processor.rb#
  # https://github.com/whitequark/ast/blob/master/lib/ast/processor/mixin.rb
  class ClassProcessor < ::Parser::AST::Processor

    def initialize
      super
      @class_names  = []
      @module_names = []
      @blacklist    = []
    end

    def class_names
      @class_names.dup.flatten
    end

    def module_names
      @module_names.dup.flatten
    end

    def process_class(node)
      node_name = _get_node_name(node)
      @class_names << node_name if node_name
      process_regular_node(node)
    end

    # # this is the same as [node]
    def get_array node
      AST::Node.new(:wrapper, [node]).children.reject &:nil?
    end

    def get_children node
      return [] unless node.is_a?(::AST::Node)
      node.children.reject &:nil?
    end

    def get_const_recursive node
      raise 'Node is not a const!' unless node.type == :const

      const_array = []

      while node
        children, const = *node
        const_array.unshift const if const
        node = children
      end

      const_array.join '::'
    end

    def _process_node opts={}
      last_parent  = opts.fetch :last_parent
      parent       = opts.fetch :parent
      current_node = opts.fetch :current_node
      names        = opts.fetch :names

      # puts "Processing: #{parent&.type} #{current_node}"

      # if we find multiple modules in a single _process_node then they are
      # guaranteed to be nested to some extent.

      valid_parent = %i(module class).include?(parent&.type)
      is_const     = valid_parent ? current_node&.type == :const : false

      if valid_parent && is_const
        parent_hash = parent.hash
        @blacklist << parent_hash
        module_name = get_const_recursive(current_node)
        names << [last_parent.hash, parent.hash, module_name]
      end

      last_parent = parent if valid_parent # track last valid module/class parent

      get_children(current_node).each do |child_node|
        _process_node last_parent: last_parent, parent: current_node, current_node: child_node, names: names
      end
    end

    def _get_node_name(start_node)
      start_node_hash = start_node.hash
      return if @blacklist.include?(start_node_hash)
      @blacklist << start_node_hash
      names = []

      get_children(start_node).each do |child|
        _process_node last_parent: start_node, parent: start_node, current_node: child, names: names
      end

      _parent_hash, root_hash, root_name = names.shift
      @root_name                         = root_name
      return root_name if names.empty? # single module name
      hash_to_name = { root_hash => root_name }

      names.each do |_, node_hash, name|
        hash_to_name[node_hash] = name
      end

      node_hierarchy = {}
      names.each do |element|
        ele_parent, ele_hash, ele_name = *element
        next if ele_hash == root_hash

        parent_name                           = hash_to_name[ele_parent]
        node_hierarchy[parent_name]           ||= {}
        node_hierarchy[parent_name][ele_name] ||= []
      end

      # --
      node_hierarchy.dup.each do |element, children|
        children.dup.each do |child_name, _child_children|
          if node_hierarchy[child_name]
            node_hierarchy[element][child_name] = node_hierarchy[child_name]
          end
        end
      end

      node_hierarchy.keys.each { |key| node_hierarchy.delete key unless key == root_name }
      # --

      # path   - accumulator
      # hash   - hash to parse
      # result - array of strings
      def collect_hash_keys(opts={})
        path   = opts.fetch :path, []
        hash   = opts.fetch :hash
        result = opts.fetch :result, []
        hash.each do |key, value|
          if value.is_a?(Hash)
            # concat path array with key array to create a new array object
            # appending will reuse the existing array object and give invalid results
            collect_hash_keys(path: path + [key], hash: value, result: result)
          else
            result << (path + [key]).join('::')
          end
        end

        result
      end

      collect_hash_keys hash: node_hierarchy
    end

    def process_module(node)
      node_name = _get_node_name(node)
      @module_names << node_name if node_name
      process_regular_node(node)
    end

    def reset
      @class_names.clear
      @module_names.clear
      @blacklist.clear
    end

    alias on_class process_class
    alias on_module process_module
  end
end
