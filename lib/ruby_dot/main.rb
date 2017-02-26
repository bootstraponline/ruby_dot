module RubyDot
  class Main

    def run file_glob
      files_to_parse = Dir.glob(file_glob)

      parser          = ::RubyDot::ClassParser.new
      file_class_hash = {}

      files_to_parse.each do |file|
        file_name = File.basename(file)

        results = parser.parse_class_names file

        # Don't allow duplicate file names (same file name @ different path)
        raise "Duplicate file name #{file_name}" if file_class_hash[file_name]
        file_class_hash[file_name]           ||= {}
        result_classes                       = results.class_names
        result_modules                       = results.module_names
        file_class_hash[file_name][:classes] = result_classes unless result_classes.empty?
        file_class_hash[file_name][:modules] = result_modules unless result_modules.empty?
      end

      file_class_hash
    end
  end
end
