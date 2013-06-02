#encoding: utf-8
require 'sinatra'
require 'redcarpet'

set :bind, '0.0.0.0'
set :port, 3000
set :markdown, layout_engine: :erb
set :erb, layout_engine: :erb

get '/' do
	posts = []
	Dir.new(File.join('.', 'views')).each do |f|
		posts.push(f.gsub('.md', '')) if f.match(/\.md$/)	
	end

  erb :index, locals: { list: posts }
end

get '/post/*' do |p|
  str = ''
	File.open File.join('.', 'views', "#{p}.md") do |f|
    str = f.read
  end

  render = renderer = Redcarpet::Render::HTML.new(:prettify => true)
  markdown = Redcarpet::Markdown.new(render, 
                                     :autolink => true, 
                                     :space_after_headers => true,
                                     :no_intra_emphasis => true,
                                     :fenced_code_blocks => true)
  html = markdown.render str
  erb :post, locals: { content: html } 
end
