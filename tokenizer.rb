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

class Snippet
  def initialize(str_ary, distance, parent_id, lang)
    @snippet = str_ary
    @distance = distance  #distance from sentence start
    @parent_id = parent_id
    @lang = lang
  end

  def permutate
    spacer = @lang == :ch ? '' : ' '
    window_result = []

    # cycle through window size from 1
    (1...@snippet.length).each do |window_size|
      left_s = 0
      left_e = 0
      right_s = window_size
      right_e = @snippet.length
      (0..@snippet.length-window_size).each do |j|
        window = @snippet[j...j+window_size]
        window_result << "(#{ActiveRecord::Base.sanitize(window.join(spacer))}, #{ActiveRecord::Base.sanitize(@snippet[left_s...left_e].join(spacer) << ' | ' <<  @snippet[right_s...@snippet.length].join(spacer))}, #{@parent_id}, #{@distance + j}, #{@snippet.length})"
        left_e += 1
        right_s += 1
      end
    end
    window_result
  end

  def to_s
    @snippet.join
  end
end

class Tokenizer < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload './*.rb'
    also_reload '*.rb'
  end

  def self.tokenize(str)
    str.delete!("\n")
    unless str =~ /\p{Han}/
      str.chomp.split /[[:blank:]]+/
    else
      arr = []
      str.each_char{ |ch| arr << ch }
      return arr
    end
  end

  def self.process(sentence, parent, lang)
    words = self.tokenize sentence
    permutations = []
    #words = words.unshift '<a>'
    max_length = [MAX_SEGMENT_LENGTH_EN, words.length].min
    (2..max_length).each do |segment_length|
      (0..words.length-segment_length).each do |i|
        snippet = Snippet.new words[i...segment_length+i], i, parent.id, lang
        permutations << snippet.permutate
      end
    end
    if permutations.length > 0
      sql = "INSERT INTO #{lang == :ch ? 'ch' : 'en'}_snippets (win, indow, ch_en_translation_id, pos, len) VALUES #{permutations.flatten.join(', ')}"
      ActiveRecord::Base.connection.execute sql
    end
  end
end
