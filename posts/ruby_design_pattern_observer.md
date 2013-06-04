ruby设计模式之观察者模式1————简单的观察者模式

观察者模式应该是最容易理解的设计模式了。

考虑这个例子。作为雇员的你当工资发生改变的时候你会想到什么？

请朋友吃饭？给女朋友买衣服？给自己买台Iphone4？

很可惜，你所增加的那点可怜的工资恐怕难以支持你做以上这些事情吧。

当你工资增加之后，你的个人所得税理所当然的增加了；你的住房公积金提高了；你的社保不出意外也要多交了。剩下来的那点应该也不够塞牙了。

这个理应是喜剧的杯具中实际上包含了观察者模式的基本概念。在这个例子中，社保局、税务局实际上是你的**观察者**。当你的工资发生变化时，你(一般来说是你的雇主)会**通知**有关部门，以便有关部门能够根据你的收入调整税收或社保政策。

下面的代码(使用ruby1.9实现，1.8y应该有问题)比较简单的实现了上面这个杯具：

	#encoding: utf-8
	class Tester
		attr_reader :name, :title, :salary
		def initialize name, title, salary
			@name = name
			@title = title
			@salary = salary
			@observers = []
		end	

		def salary=new_salary
			@salary = new_salary
			notify_observers
		end

		def notify_observers
			@observers.each do |ob|
				ob.update self
			end
		end
		
		def add_observer ob
			@observers << ob
		end

		def delete_observer ob
			@observers.delete ob
		end
	end

	class YouKnow
		def update changed_tester
			puts "#{self.class.to_s} 盯上 #{changed_tester.name}了".encode('gb2312')
			puts "#{changed_tester.name}的工资变成#{changed_tester.salary}了".encode('gb2312')
			puts "#{changed_tester.name}要多交......".encode('gb2312')
		end
	end

	class I税务局I < YouKnow;end
	class I社保局I < YouKnow;end

	you = Tester.new('你', '', 2000)

	you.add_observer(I税务局I.new)
	you.salary = 5000

上面的例子将输出:

> ruby observer.rb
> I税务局I 盯上 你了
> 你的工资变成5000了
> 你要多交......
> Exit code: 0


在上面的代码中，类Tester实现了观察者模式。

Tester维护了1个叫做@observers的数组，该数组用来保存所有的观察者实例。

在Tester中最重要的1个方法是salary=new\_salary。当Tester的salary发生变化时，notify\_observers方法将会被调用。

notify_observers方法会遍历所有的observer，然后调用observer的update方法。

observer的update方法以Tester的实例作为参数，这样做主要是为了能够更方便的访问Tester的属性如name，title。

于是简而言之Tester类会有一系列的观察者，这些观察者对Tester的一些属性感兴趣，在这里是salary。于是当salary发生改变时，Tester会通知各个观察者去update Tester状态。在这个例子里就是去update Tester的salary属性。

这就是观察者模式的核心理念。观察者模式不是观察者真正的去观察被观察者，而是被观察者在发生改变的时候主动去通知被观察者。
