# encoding: UTF-8

require 'pry'
require 'awesome_print'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/streaming'
require 'sinatra/reloader' if development?
require 'haml'
require 'nokogiri'
require './library'
require './tokenizer'
require './analyzer'
require 'iconv'

get '/parse' do
  stream do |out|
    $out = out #debug
    kheperize 'data'
  end
end


get '/encoding' do
  @encodings = []
  @folders = Dir['corpora/*/']
  haml :encoding
end

post '/encoding' do
  @encodings = {}
  @folders = Dir["#{params[:folder]}*/"]
  unless @folders.length > 0
    librbfiles = File.join("**", params[:folder], "**", "*")
    filename = Dir.glob(librbfiles).first
    CHINESE_ENCODINGS.each do |encoding|
      file = TranslationFile.new "#{filename}", external_encoding: encoding
      @encodings[encoding] = []
      file.each do |line|
        @encodings[encoding] << "#{::Iconv.conv('UTF-8//IGNORE', 'UTF-8', line + ' ')[0..-2]}"
      end
    end
  end
  haml :encoding
end

get '/import/:encoding/*' do
  stream do |out|

  template = File.read('views/layout.haml')
  #out << Haml::Engine.new(template).render(Proc.new {|n| n}, :foo => 's')
  folder = params[:splat][0]
  files = Dir.entries(folder) - %w(. .. .DS_Store)  #skip system files
  files.each do |filename|
    out << "#{folder}#{filename.gsub(/raw/,'eng')}" << '<br>'
    file1 = TranslationFile.new "#{folder}#{filename}", external_encoding: params[:encoding]
    file2 = TranslationFile.new "#{File.dirname folder}/English/#{filename.gsub(/raw/,'eng')}"
    chinese = Nokogiri::XML(file1.read.gsub(/ID=(\d+)/, 'ID="\1"')).css('S')
    english = Nokogiri::XML(file2.read.gsub(/ID=(\d+)/, 'ID="\1"')).css('S')

    (0...chinese.length).each do |i|
      begin
        translation = ChEnTranslation.create! :ch => chinese[i].text, :en =>  english[i].text, :source => params[:splat][0]
        Tokenizer.process(translation.en, translation, :en) if translation
        Tokenizer.process(translation.ch, translation, :ch) if translation
      rescue => e
      end
    end
  end

  end
end

get '/align/:word' do
  translations = Analyzer.analyze params[:word]
end

get '/' do
  haml :layout
end


