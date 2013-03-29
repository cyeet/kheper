# encoding: UTF-8

require 'pry'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/streaming'
require 'sinatra/reloader' if development?
require 'haml'
require './library'
require './tokenizer'

get '/parse' do
  haml :layout
  stream do |out|
    $out = out #debug
    kheperize 'data'
  end
end

def kheperize(folder)
  files = Dir.entries(folder) - %w(. .. .DS_Store)  #skip . .. files
  files.each do |path|
    binding.pry
    file = Tokenizer::Parser.new "#{folder}/#{path}", external_encoding:'utf-8'
    file.take(10).each do |line|
    binding.pry
      # for each line
      words = Tokenizer.tokenize(line).unshift('<s>')
      Tokenizer.process(words)
    end
  end
  #f1.each.zip(f2.each).each do |line1, line2|
      # Do something with the lines
    # end
end
