Ruby是一门很神器的脚本语言，从理论上讲编译语言能做的事情ruby都能做。很多同学在学习ruby的时候总感觉ruby虽然使用简单，但是功能确实不太强大，在日常的工作中很难用上。这时候我们可能就需要使用ruby写一些有趣的东西来帮助我们突破瓶颈完成自我超越。
===================================

在这里我们且看一下如何使用ruby来实现一个简单的window窗体。

首先我们需要安装fxruby这个gem扩展。Ruby1.8.6原生安装了这个库，其他版本的ruby使用gem安装一下既可。

	Gem install fxruby

下面摘抄关于fxruby的官方说明。
----------------------------

> FXRuby is a library for developing powerful and sophisticated cross-platform graphical user interfaces (GUIs) for your Ruby applications. It’s based on the FOX Toolkit, a popular open source C++ library developed by Jeroen van der Zijp. What that means for you as an application developer is that you’re able to write code in the Ruby programming language that you already know and love, while at the same time taking advantage of the performance and functionality of a featureful, highly optimized C++ toolkit.

下面是使用fxruby实现简单窗口的代码。
-----------------------------------
	require 'rubygems'

	
	require 'fox16' #require fxruby


	include Fox # include Fox module，一般来说不会带来命名空间问题


	class MyWindow < FXMainWindow #写一个FXMainWindow的子类


	def initialize app #覆盖父类的构造函数，并设置窗口的标题和宽高


	super app, 'My Window', :width => 600, :height => 400


	end


	def create #实现create方法，主要是提供show的方式


	super


	show PLACEMENT_SCREEN


	end


	end


	if __FILE__ == $0 #如果是当前文件


	app = FXApp.new 'My window', 'My window' #创建FXapp


	main_window = MyWindow.new app #创建MyWindow窗体


	app.create #显示窗体


	app.run # 运行程序


	end

