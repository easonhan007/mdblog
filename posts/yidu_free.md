YiduFreeTxt 0.1beta版
====================
天涯易读网站原本是有提供下载全帖txt版本的功能的，但是该功能需要易读积分，这对于从来不登陆易读的笔者来说，无疑是一件不可能完成的任务。

于是随手写了个免费将易读全贴转换成txt文件的小工具，一来自娱自乐，二来献给老婆。因为老婆最近都在易读追帖，一天花掉30M的流量，让亲者痛，仇者快（好吧，我是亲者，移动是仇者）。

自从有了YiduFreeTxt，哪里要看点哪里，一键转成txt，老公再也不用担心我的流量了。

### 一些必要的说明

YiduFreeTxt使用ruby192开发，所以没有安装ruby的同学，或者ruby版本不符的同学可能没有办法进行试用。

YiduFreeTxt使用nokogiri库进行html的解析，请确保你的本地gem安装了nokogiri扩展。若没有，请输入命令 gem install nokogiri。

由于作者的不勤奋及时间关系，YiduFreeTxt要求大家输入天涯易读帖子url中的article id，不是直接输入url。举例来说，下面这个帖子

http://tianyayidu.com/article-a-102005.html中的102005就是该帖子的article id，使用时请注意。

### 关于代码

这里贴出该工具的相关代码，供有兴趣的同学研究。为什么没有一行注释？没办法，作者太懒，什么注释都没留下。

	require 'rubygems'
	require 'nokogiri'
	require 'open-uri'
	require 'logger'
	class String
		def br_to_new_line
			self.gsub('<br>', "\n")
		end
		
		def strip_tag
			self.gsub(%r[<[^>]*>], '')
		end
			
	end #String
	module YiDu
		class UrlBuilder
			attr_reader :domain, :id, :article
			attr_reader :end_type
			def initialize id
				@domain = %q[http://tianyayidu.com/]
				@article = 'article'
				@end_type = '.html'
				@id = id.to_s
			end		
			
			def article_url
				@domain + @article + '-'+ id + @end_type
			end #article_url		
			
			def build_article_url page
				page = page.to_s
				"#{@domain}#{@article}-#{@id}-#{page+@end_type}"
			end #build_article_url		
		end #UrlBuilder
		
		class ContentWorker
			attr_reader :url, :doc, :retry_time
			attr_accessor :page_css, :content_css
			
			class << self
				def log=(log_file)
					@@log = log_file
				end #log=
				
				def log
					@@log
				end
			end #class
			
			def initialize url
				@url = url
				define_max_retry_time
				define_page_css
				define_content_css
				get_nokogiri_doc
				exit if @doc.nil?
				log_or_output_info
			end #initialize		
			
			def log_or_output_info
				msg = "processing #{@url}"
				if @@log
					@@log.debug msg
				else
					puts msg
				end #if
			end	#log_or_output_info	
					
			def get_nokogiri_doc
				times = 0
				begin
					@doc = Nokogiri::HTML(open(@url).read.strip)
				rescue
					@@log.error "Can Not Open [#{@url}]" if @@log
					times += 1
					retry if(times < @retry_time)
				end #begin
			end #get_nokogiri_doc
			
			def define_max_retry_time
				@retry_time = 3
			end #define_max_retry_time
			
			def define_page_css
				@page_css = %q[div.pageNum2]
			end
			
			def define_content_css
				@content_css = %q[li.at.c.h2]
			end #define_content_css
			
			def total_page
				page = ''
				doc.css(page_css).each do |p|
					m = p.content.match(/\d+/)				
					page = m[0] if m								
				end #each
				page.to_i
			end #total_page
			
			def build_content &blk
				@doc.css(@content_css).each do |li|
					if block_given?
						blk.call(li.to_html.br_to_new_line.strip_tag)
					else
						puts li.to_html.br_to_new_line.strip_tag
					end #if
				end #each 
			end #build_content
			
		end #ContentWorker
		
		class IoFactory
			attr_reader :file
			def self.init file
				@file = file
				if @file.nil?
					puts 'Can Not Init File To Write'
					exit
				end #if
				File.open @file, 'a'
			end		
		end #IoFactory
		
		class Runner		
				attr_reader :url_builder, :start_url
				attr_reader :total_page, :file_to_write
				
				def initialize id
					init_logger
					@url_builder = UrlBuilder.new(id)				
					get_start_url
					get_total_page
					create_file_to_write id				
					output_content
				end #initialize
				
				def self.go(id)
					self.new(id)
				end
				
				def create_file_to_write id
					file_path = File.join('.', id.to_s.concat('.txt'))
					@file_to_write = IoFactory.init(file_path)
				end #create_file_to_write
				
				def init_logger
					logger_file = IoFactory.init('./log.txt')
					logger = Logger.new logger_file
					ContentWorker.log = logger
				end #init_logger
				
				def get_start_url				
					@start_url = @url_builder.article_url
				end #get_start_url
				
				def get_total_page
					@total_page = ContentWorker.new(@start_url).total_page
					if @total_page.nil?
						puts 'Can not get total page'
						exit
					end #if
				end # get_total_page
				
				def output_content				
					@total_page.times do |part|
						a_url = @url_builder.build_article_url(part+1)
						ContentWorker.new(a_url).build_content do |c|
							@file_to_write.puts c
							@file_to_write.puts '*' * 40
						end # build_content
					end #times
				end #output_content
			
		end #Runner
	end #YiDu

	include YiDu
	id = 102005
	Runner.go id

### 代码结构分析

为了帮助大家学习ruby，小弟还是画蛇添足的分析一下代码好了。

YiduFreeTxt主要由3个模块构成：UrlBuilder，ContentWorker和Runner。

* UrlBuilder主要用来生成易读全贴各个分页的url及首页的url;

* ContentWorker则负责使用nokogiri从html页面中拿到帖子的所有分页数和每个分页的主体内容；

* Runner的作用是协调UrlBuilder和ContentWorker，使其协同工作，并将获取的内容写入文件；

### 代码亮点

写的很烂，没啥亮点，唯一有点成就感的就是build_content方法可以将&blk传入block，这点以前没有注意到。

### 版权

未经许可，也可转载。


### 扩展

写了个看似没啥作用的IoFactory实际上是考虑到以后的扩展性，如果需要把内容输出到pdf文件的话，那么只需要继承IoFactory,并使其返回的文件句柄响应puts方法既可，算是实现了一个丑陋的Adapter模式。









