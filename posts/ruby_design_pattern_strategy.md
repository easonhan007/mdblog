### Ruby设计模式之策略模式一： 基本的策略模式

模板模式固然不错，但其还是有一些缺陷的。比如其实现依赖于继承并且缺足够的灵活性。在这时候我们就需要找到一个更加优化的解决方案——策略模式。

下面是使用策略模式实现的Report模板

	#encoding: utf-8

	class Formatter
		def output_report title, text
			raise 'can not call Abstract method'	
		end
	end

	class HTMLFormatter < Formatter
		def output_report title, text
			puts '<html>'
			puts '    <head>'
			puts '        <title>' + title + '</title>'
			puts '    </head>'
			puts '    <body>'
			text.each do |line|
				puts "<p>#{line}</p>"
			end
			puts '    </body>'
			puts '</html>'
		end
	end

	class PlainTextFormatter < Formatter
		def output_report title, text
			puts '******** ' + title + ' ********'
			text.each do |line|
				puts line
			end
		end
	end

	class Reporter
		attr_reader :title, :text
		attr_accessor :formater

		def initialize formater
			@title = 'My Report'
			@text = ['This is my report', 'Please see the report', 'It is ok']
			@formater = formater
		end

		def output_report
			@formater.output_report @title, @text
		end
	end

	Reporter.new(HTMLFormatter.new).output_report
	Reporter.new(PlainTextFormatter.new).output_report

GOF将Strategy模式称之为__pull the algorithm out  into a separate object__，其基本理念就是实现一系列strategies对象，这些对象全都实现相同的功能。在上面的例子中这些strategies对象的功能就是输入报告。

Strategies对象除了实现相同功能之外，还需要定义统一的接口。上面的例子里就是实现了output_report方法。

使用这些Strategies的类被GOF称之为context。context可以调用任意的strategies，在context看来这些strategies并没有什么不一样，因为它们都实现了同样的功能。不过选择不同的strategies还是有些许不同的。在上面的例子里，选择HTMLFormatter可以输出HTML报告，而选择PlainTextFormatter则输入另一种风格的报告。如果我们实现一个住房公积金计算器，那么我们可以实现多个不同的strategy，1个strategy用来实现深圳的公积金算法，1个实现上海的算法，1个实现北京的算法如此类推。

#### 策略模式有如下的优点

* 策略模式可以分离不同算法的代码，而且context不需要知道任何有关strategy的实现细节，其只需要调用strategy所定义的接口既可。

* 另外在context中，切换strategy的成本低廉且灵活。 




