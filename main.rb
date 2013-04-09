# encoding: UTF-8

require 'pry'
require 'awesome_print'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/streaming'
require 'sinatra/reloader' if development?
require 'will_paginate'
require 'will_paginate/active_record'
require 'haml'
require 'nokogiri'
require './library'
require './tokenizer'
require './analyzer'
require 'iconv'

get '/' do
  haml :index
end

get '/translate' do
  haml :translate
end

get '/translations' do
  @translations = ZhEnTranslation.page(params[:page])
  haml :translations
end

get '/encoding' do
  @folders = params[:folder] ? Dir["#{params[:folder]}*/"] : Dir['*/']

  unless @folders.length > 0
    librbfiles = File.join("**", params[:folder], "**", "*")
    @filenames = Dir.glob(librbfiles)
  end

  if params[:filename]
    @encodings = {}
    CHINESE_ENCODINGS.each do |encoding|
      file = TranslationFile.new "#{params[:filename]}", external_encoding: encoding
      @encodings[encoding] = []
      file.each_with_index do |line, i|
        @encodings[encoding] << "#{::Iconv.conv('UTF-8//IGNORE', 'UTF-8', line + ' ')[0..-2]}"
        break if i > 20
      end
    end
  end
  haml :encoding
end

get '/align/:word' do
  @candidates = []
  unless params[:word] == 'postechkle'
    @candidates = Analyzer.analyze params[:word]
    @candidates = @candidates.sort_by { |candidate| candidate[1] }
  end
  haml :align
end

get '/tr' do
  arr = [1]
  @snippet = %w(1 2 3 4 5 6 7 8 9 10)
  (1...@snippet.length).each do |window_size|
    left_s = 0
    left_e = 0
    right_s = window_size
    right_e = @snippet.length
    (0..@snippet.length-window_size).each do |j|
      window = @snippet[j...j+window_size]
      arr << window
      left_e += 1
      right_s += 1
    end
  end
  ap arr
end

def preprocess(str)
  str = str.delete("\n")
  str = Tokenizer.tokenize str
end

get '/dictionary/:language' do
  @language = params[:language]
  if params[:filename]
    file = TranslationFile.new params[:filename], external_encoding: params[:encoding]
    file.each do |line|
      zh, en = line.split("\t")
      next unless zh
      zh = zh.gsub /(\[.+\]|\(.+\))/, ''
      ens = en.split('/').values_at(1...-1)
      ens.each do |en|
        begin
          ZhDictionary.create :zh => zh, :en => en, :len => zh.length
        rescue => e
        end
      end
    end
  end
  @definitions = ZhDictionary.order('zh').page(params[:page])
  haml :dictionary
end

get '/import' do
  stream do |out|

  template = File.read('views/layout.haml')
  #out << Haml::Engine.new(template).render(Proc.new {|n| n}, :foo => 's')
  folder = File.dirname params[:filename]
  files = Dir.entries(folder) - %w(. .. .DS_Store)  #skip system files
  files.take(1).each do |filename|
    file1 = TranslationFile.new "#{folder}/#{filename}", external_encoding: params[:encoding]

    out << "#{File.dirname folder}/English/#{filename.gsub(/raw/,'eng')}"
    file2 = TranslationFile.new "#{File.dirname folder}/English/#{filename.gsub(/raw/,'eng')}"
    chinese = Nokogiri::XML(file1.read.gsub(/ID=(\d+)/, 'ID="\1"')).css('S')
    english = Nokogiri::XML(file2.read.gsub(/ID=(\d+)/, 'ID="\1"')).css('S')

    (0...chinese.length).each do |i|
      begin
        translation = ZhEnTranslation.create! :zh => chinese[i].text, :en =>  english[i].text, :source => params[:filename]
        Tokenizer.process(translation.en, translation, :en) if translation
        Tokenizer.process(translation.zh, translation, :zh) if translation
      rescue => e
      end
    end
  end

  end
end
