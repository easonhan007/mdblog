#encoding: utf-8
require 'sinatra'
require 'redcarpet'

set :bind, '0.0.0.0'
set :port, 3000

get '/' do
	post_list = '<h2>乙醇的blog</h2>'

	posts = []
	Dir.new(File.join('.', 'views')).each do |f|
		posts.push(f.gsub('.md', '')) if f.match(/\.md$/)	
	end
	posts.each do |p|
		post_list += "<a href=\"post/#{p}\">#{p}</a>"
		post_list += '<br />'
	end 
	post_list
end

get '/post/*' do |p|
	markdown p.to_sym
end
