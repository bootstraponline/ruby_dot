module RubyDot
  class Main

    # file_glob - file glob of Ruby files
    # @return [Hash] hash of found classes/modules keyed on file name
    def run file_glob
      files_to_parse = Dir.glob(file_glob)

      parser          = ::RubyDot::ClassParser.new
      file_class_hash = {}

      files_to_parse.each do |file|
        file_name = File.basename(file)

        results = parser.parse_class_names file

        # Don't allow duplicate file names (same file name @ different path)
        raise "Duplicate file name #{file_name}" if file_class_hash[file_name]
        file_class_hash[file_name]         ||= {}
        result_names                       = results.names
        file_class_hash[file_name][:names] = result_names unless result_names.empty?
      end

      file_class_hash
    end
  end
end
