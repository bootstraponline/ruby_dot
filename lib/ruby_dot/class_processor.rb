module RubyDot
  # Collect fully qualified class & module names
  #
  # https://github.com/whitequark/parser/blob/master/lib/parser/ast/processor.rb#
  # https://github.com/whitequark/ast/blob/master/lib/ast/processor/mixin.rb
  class ClassProcessor < ::Parser::AST::Processor

    def initialize
      super
      reset
    end

    def reset
      @state   = []
      @state_h = []
      @known_h = [] # don't save same hash multiple times
      @names   = []
      @debug   = false # enable for debugging
    end

    def log(*args)
      puts(*args) if @debug
    end

    def names
      @names.dup
    end

    def get_name node
      raise 'Node is not a const!' unless node.type == :const

      # loc.name doesn't recurse (module H::I::J)
      # name = node.loc.name.source

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

      const_type, = *name_const

      # module A
      #   module ::B # cbase
      #   end
      # end
      #
      # [A, B] not [A::B]
      cbase       = const_type && const_type.type == :cbase

      log "before: node: #{name} hash: #{node_hash_string} state: #{@state} cbase: #{cbase}"

      if cbase
        unless @known_h.include? node_hash
          @names << @state.join('::')
          log "saved: #{@names.last} cbase: #{cbase}"
        end
        @known_h.concat(@state_h)
        @state.clear
        @state_h.clear
      end

      # before node is processed
      @state << name
      @state_h << node_hash

      # process node
      original_node = process_regular_node(node)

      log "after:  node: #{name} hash: #{node_hash_string} state: #{@state} cbase: #{cbase}"


      # after node is processed
      if node_hash == @state_h.first
        unless @known_h.include? node_hash
          @names << @state.join('::')
          log "saved: #{@names.last} first hash"
        end
        @known_h.concat(@state_h)
        @state.clear
        @state_h.clear
      elsif node_hash == @state_h.last
        unless @known_h.include? node_hash
          @names << @state.join('::')
          log "saved: #{@names.last} last hash"
        end

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

    alias on_class process_class
    alias on_module process_module
  end
end
