# encoding: UTF-8

require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/streaming'
require 'sinatra/reloader' if development?
require './library'
require './tokenizer'

get '/' do
  stream do |out|
    me = EnglishPhrase.first
    file = Tokenizer::Parser.new 'data.txt', 'CP950'
    file.each do |line|
      out << "#{Tokenizer.tokenize(line)}\n"
    end
  end
end

