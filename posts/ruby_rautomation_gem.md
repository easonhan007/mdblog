使用rautomation进行windows窗体的自动化测试
==========================================

今天在本地的gem list中发现了1个叫做rautomation的扩展，仔细一看原来这是个使用watir的语法进行windows程序测试的工具库，不敢独享，略志一二。

### 首先看一下rautomation的简介

> RAutomation is a small and easy to use library for helping out to automate windows and their controls for automated testing.
> RAutomation是个小巧易用的工具库，其主要用来进行windows窗体和控件的自动化测试工作。

### RAutomation的特点

* Easy to use and user-friendly API (inspired by Watir http://www.watir.com) __易用的watir like API__
* Cross-platform compatibility __跨平台__
* Easy extensibility - with small scripting effort it's possible to add support for not yet supported platforms or technologies __易扩展__

### RAutomation的用法

    require "rautomation"
    
	# 通过匹配部分标题来获取窗口
    window = RAutomation::Window.new(:title => /part of the title/i)
    window.exists? # => true
    window.title # => "blah blah part Of the title blah"
    window.text # => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec ultricies..."
   
	# 控件操作
    window.text_field(:class => "Edit", :index => 0).set "hello, world!"
    button = window.button(:text => "&Save")
    button.exists? # => true
    button.click
    
    # 获取当前所有窗口的句柄
	all_windows = RAutomation::Window.windows
    all_windows.each {|window| puts window.hwnd}
    
	# 根据标题匹配所有窗口
    window = RAutomation::Window.new(:title => /part of the title/i)
    windows = window.windows
    puts windows.size # => 2
    windows.map {|window| window.title } # => ["part of the title 1", "part of the title 2"]
    window.windows(:title => /part of other title/i) # => all windows with matching specified title
    
	# 遍历窗口上所有的button控件
    window.buttons.each {|button| puts button.value}
    window.buttons(:value => /some value/i).each {|button| puts button.value}
    
	# 使用autoit adapter来定位和操作窗口
	# 注意：需要注册AutoitX的DLL
    window2 = RAutomation::Window.new(:title => "Other Title", :adapter => :autoit) # use AutoIt adapter
	# 使用autoit的原生方法来操作控件
    # use adapter's (in this case AutoIt's) internal methods not part of the public API directly
    window2.WinClose("[TITLE:Other Title]")

### RAutomation的安装
安装了watir 1.9后该扩展自动安装。另外也可以使用下面的命令进行安装

	gem install rautomation





