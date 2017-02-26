module RubyDot
  class ClassParser

    attr_reader :parser, :class_processor

    def initialize
      @parser          = Parser::CurrentRuby.new
      @class_processor = ClassProcessor.new
    end

    def parse_class_names file_path
      raise "File does not exist! #{file_path}" unless File.exist? file_path

      parser.reset
      source = Parser::Source::Buffer.new(file_path).read
      ast    = parser.parse source

      class_processor.reset
      class_processor.process(ast)
      class_processor
    end
  end
end
