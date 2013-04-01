# encoding: UTF-8

require 'pry'
require 'awesome_print'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/streaming'
require 'sinatra/reloader' if development?
require 'haml'
require 'xmlsimple'
require './library'
require './tokenizer'

get '/parse' do
  haml :layout
  stream do |out|
    $out = out #debug
    kheperize 'data'
  end
end

get '/encoding' do
  output = []
  output << ('Empty')
  filename = 'corpora/ch_news_trans/data/translation/AFC20020701.0014.sgm'
  CHINESE_ENCODINGS.each do |encoding|
    file = TranslationFile.new "#{filename}", external_encoding: encoding
    file.take(10).each do |line|
      output << encoding << "#{line}<br/>" unless line.nil? || line.empty?
    end
  end
  output
end

get '/import' do
  stream do |out|

  folder = 'data/cd.data'
  files = Dir.entries("#{folder}/Chinese") - %w(. .. .DS_Store)  #skip system files
  files.each do |filename|
    out << filename << '<br>'
    file1 = TranslationFile.new "#{folder}/Chinese/#{filename}", external_encoding:'utf-8'
    file2 = TranslationFile.new "#{folder}/English/#{filename.gsub(/raw/,'eng')}", external_encoding:'utf-8'

    file2.each do |line1|
      out << line1
    end
  end

  end
end

get '/' do
  haml :layout
end

def kheperize(folder)
  files = Dir.entries(folder) - %w(. .. .DS_Store)  #skip . .. files
  files.each do |path|
    file = TranslationFile.new "#{folder}/#{path}", external_encoding:'utf-8'
    file.take(10).each do |line|
      words = Tokenizer.tokenize line
      Tokenizer.process words
    end
  end
end
