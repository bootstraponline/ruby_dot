require_relative '../lib/ruby_dot'
require 'json'

path      = File.join(__dir__, '../lib/ruby_dot/**/*.rb')
class_map = RubyDot::Main.new.run path

output = File.join(__dir__, 'class_map.rb')

File.write output, JSON.pretty_generate(class_map)
