#encoding: utf-8
Encoding.default_external = "UTF-8"
require 'sinatra'
require 'redcarpet'

set :bind, '0.0.0.0'
set :port, 3000
set :erb, layout_engine: :erb
posts_dir = File.join('.', 'posts') 
html_dir = File.join('.', 'public', 'p') 

get '/' do
	posts = []
	Dir.new(html_dir).each do |f|
		posts.push(f.encode('utf-8').gsub('.html', '')) if f.match(/\.html$/)	
	end

  erb :index, locals: { list: posts }
end

get '/post/*' do |p|
	render_md(p, posts_dir)
end

get '/list' do
	posts = []
	Dir.new(posts_dir).each do |f|
		posts.push(f.encode('utf-8').gsub('.md', '')) if f.match(/\.md$/)	
	end

	erb :list, locals: { list: posts }
end

get '/build/*' do |p|
	request = Rack::MockRequest.new(Sinatra::Application)
	html = request.get("/post/#{p}").body
	html_path = File.join(html_dir, "#{p}.html") 
	File.open(html_path, 'w') do |f|
		f.write html
	end
	redirect to('/')
end

def render_md(file, posts_dir)
  str = ''
	File.open File.join(posts_dir, "#{file}.md") do |f|
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
