require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/streaming'
require "sinatra/reloader" if development?

get '/' do
  stream do |out|
    me = EnglishPhrase.first
    out << "#{me.original}\n"
    sleep 5
    out << "#{EnglishPhrase.last.original}\n"
   out << 'huuuwwwwe'
  end
end

class EnglishPhrase < ActiveRecord::Base
end
