require 'rubygems'
require 'parser/current'
require 'mustache'
Parser::Builders::Default.emit_lambda   = true
Parser::Builders::Default.emit_procarg0 = true

require_relative 'ruby_dot/ruby_dot'
