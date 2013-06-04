#encoding: utf-8
Encoding.default_external = "UTF-8"
require 'sinatra'
require 'redcarpet'

set :bind, '0.0.0.0'
set :port, 3000
set :erb, layout_engine: :erb
posts_dir = File.join('.', 'posts') 

get '/' do
	posts = []
	Dir.new(posts_dir).each do |f|
		posts.push(f.gsub('.md', '')) if f.match(/\.md$/)	
	end

  erb :index, locals: { list: posts }
end

get '/post/*' do |p|
  str = ''
	File.open File.join(posts_dir, "#{p}.md") do |f|
    str = f.read
  end

  render = Redcarpet::Render::HTML.new(:prettify => true)
  markdown = Redcarpet::Markdown.new(render, 
                                     :autolink => true, 
                                     :space_after_headers => true,
                                     :no_intra_emphasis => true,
                                     :fenced_code_blocks => true)
  html = markdown.render str
  erb :post, locals: { content: html, layout: true } 

end
