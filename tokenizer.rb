require 'stringio'
require 'sinatra/base'
require 'sinatra/reloader'

class Parser
  include Enumerable

  def initialize(path, external_encoding: 'utf-8')
    raise ArgumentError unless File.exists?(path) and !File.directory?(path)
    @log = File.open(path, "r:#{external_encoding}:utf-8")
  end

  def each(&block)
    @log.each_line do | line |
      yield line
    end
  end
end

class Tokenizer < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload './*.rb'
    also_reload '*.rb'
  end

  def self.tokenize(str)
    unless str =~ /\p{Han}/
      str.chomp.split /[[:blank:]]+/
    else
      arr = []
      str.each_char{ |ch| arr << ch }
      return arr
    end
  end

  def self.process(words)
    #words = words.unshift '<a>'
    window_result = []
    inverted_result = []
    (-MAXIMUM_WORD_LENGTH+2..words.length).each do |i|
      snippet = words[[i,0].max...MAXIMUM_WORD_LENGTH+i]
      $out << "\n\n<br>SNIPPET: " << snippet << "<br>\n"

      # cycle through window size from 1 ... snippet end
      (1...snippet.length).each do |window_size|
        left_s = 0
        left_e = 0
        right_s = window_size
        right_e = snippet.length
        (0..snippet.length-window_size).each do |j|
          window = snippet[j...j+window_size]
          window_result << [window.join,
            "#{snippet[left_s...left_e].join} | #{snippet[right_s...snippet.length].join}"]
          left_e += 1
          right_s += 1
        end
      end
    end
    binding.pry
    $out << "\n\n<br>window: " << window_result << "<br>\n"
    $out << "\n\n<br>inverted: " << inverted_result << "<br>\n"
  end
end
