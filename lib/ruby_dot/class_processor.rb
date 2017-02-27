module RubyDot
  # Collect fully qualified class & module names
  #
  # https://github.com/whitequark/parser/blob/master/lib/parser/ast/processor.rb#
  # https://github.com/whitequark/ast/blob/master/lib/ast/processor/mixin.rb
  class ClassProcessor < ::Parser::AST::Processor

    def initialize
      super
      @state   = []
      @state_h = []
      @known_h = [] # don't save same hash multiple times
      @names   = []
    end

    def class_names
      []
    end

    def names
      @names.dup
    end

    def get_name node
      raise 'Node is not a const!' unless node.type == :const

      const_array = []

      while node
        children, const = *node
        const_array.unshift const if const
        node = children
      end

      const_array.join '::'
    end

    def _find_name(node)
      name_const, _body = *node
      node_hash         = node.hash
      node_hash_string  = node_hash.abs.to_s(16)[0..4]
      name              = get_name(name_const)

      puts "before: node: #{name} hash: #{node_hash_string} state: #{@state}"
      # before node is processed
      @state << name
      @state_h << node_hash

      # process node
      original_node = process_regular_node(node)

      puts "after:  node: #{name} hash: #{node_hash_string} state: #{@state}"


      # after node is processed
      if node_hash == @state_h.first
        @names << @state.join('::') unless @known_h.include? node_hash
        puts "saved: #{@names.last} first hash"
        @known_h.concat(@state_h)
        @state.clear
        @state_h.clear
      elsif node_hash == @state_h.last
        @names << @state.join('::') unless @known_h.include? node_hash
        puts "saved: #{@names.last} last hash"

        @state.pop
        @state_h.pop
        @known_h.concat(@state_h)
      end

      original_node
    end

    def process_class(node)
      _find_name node
    end

    def process_module(node)
      _find_name node
    end

    def reset
      @state.clear
      @names.clear
    end

    alias on_class process_class
    alias on_module process_module
  end
end
