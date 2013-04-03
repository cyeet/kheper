require 'stringio'
require 'sinatra/base'
require 'sinatra/reloader'

class TranslationFile
  include Enumerable

  def initialize(path, external_encoding: 'utf-8')
    raise ArgumentError unless File.exists?(path) and !File.directory?(path)
    @log = File.open(path, "r:#{external_encoding}:utf-8")
  end

  def read
    out = @log.read
    @log.rewind
    out
  end

  def each(&block)
    @log.each_line do | line |
      yield line
    end
  rescue
    yield ''
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
    max_length = [MAX_SEGMENT_LENGTH_EN, words.length].min
    window_result = []
    inverted_result = []
    (2..max_length).each do |segment_length|
      (0..words.length-segment_length).each do |i|
        snippet = words[i...segment_length+i]
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
    end
    binding.pry
    $out << "\n\n<br>window: " << window_result << "<br>\n"
    $out << "\n\n<br>inverted: " << inverted_result << "<br>\n"
  end
end
